import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
const TAG="\$";
const SRC="./jsons"; //JSON 目录
const DIST="./models/"; //输出model目录

void walk() { //遍历JSON目录生成模板
  var src = Directory(SRC);
  var list = src.listSync();
  var template= File("./template.txt").readAsStringSync();
  File file;
  list.forEach((f) {
    if (FileSystemEntity.isFileSync(f.path)) {
      file =  File(f.path);
      var paths=path.basename(f.path).split(".");
      String name=paths.first;
      if(paths.last.toLowerCase()!="json"||name.startsWith("_")) return ;
      if(name.startsWith("_")) return;
      //下面生成模板
      var map = json.decode(file.readAsStringSync());
      //为了避免重复导入相同的包，我们用Set来保存生成的import语句。
      var set=  Set<String>();
      StringBuffer attrs=  StringBuffer();
      (map as Map<String, dynamic>).forEach((key, v) {
          if(key.startsWith("_")) return ;
          attrs.write(getType(v,set,name));
          attrs.write(" ");
          //attrs.write(key); //原来
          attrs.write(changeFileNameToInstanceName(key)); //johnny修改后
          attrs.writeln(";");
          attrs.write("    ");
      });

      var extendsResponse = "";//johnny添加
      StringBuffer overrideCodes = StringBuffer();//johnny添加
      if(name.contains("_response"))
      {
        extendsResponse = "extends ApiBaseResponse";
        overrideCodes.writeln("@override");
        overrideCodes.writeln("    String getCode()");
        overrideCodes.writeln("    {");
        overrideCodes.writeln("      return this.code;");
        overrideCodes.writeln("    }");
        overrideCodes.writeln("");
        overrideCodes.writeln("    @override");
        overrideCodes.writeln("    String getMessage()");
        overrideCodes.writeln("    {");
        overrideCodes.writeln("      return this.message;");
        overrideCodes.writeln("    }");
      }

      //String className=name[0].toUpperCase()+name.substring(1);//原来
      String className = changeFileNameToClassName(name); //johnny修改后

      var dist=format(template,[name,className,extendsResponse,className,attrs.toString(),
                                className,className,className,overrideCodes.toString()]);
      var _import=set.join(";\r\n");
      _import+=_import.isEmpty?"":";";
      dist=dist.replaceFirst("%t",_import );
      //将生成的模板输出
       File("$DIST$name.dart").writeAsStringSync(dist);
    }
  });
}

String changeFirstChar(String str, [bool upper=true] ){
  return (upper?str[0].toUpperCase():str[0].toLowerCase())+str.substring(1);
}

//johnny添加的方法
String changeFileNameToClassName(String fileName)
{
  var splitNames = fileName.split("_");
  var className = "";
  for(var i=0; i< splitNames.length; i++)
  {
    className += changeFirstChar(splitNames[i], true);
  }
  return className;
}

//johnny添加的方法
String changeFileNameToInstanceName(String fileName)
{
  var splitNames = fileName.split("_");
  var className = "";
  for(var i=0; i< splitNames.length; i++)
  {
    if(i == 0)
    {
      className = changeFirstChar(splitNames[i], false);
    }
    else{
      className += changeFirstChar(splitNames[i], true);
    }
  }
  return className;
}



//将JSON类型转为对应的dart类型
 String getType(v,Set<String> set,String current){
  current=current.toLowerCase();
  if(v is bool){
    return "bool";
  }else if(v is num){
    return "num";
  }else if(v is Map){
    return "Map<String,dynamic>";
  }else if(v is List){
    return "List";
  }else if(v is String){ //处理特殊标志
    if(v.startsWith("$TAG[]")){
      //var className=changeFirstChar(v.substring(3),false); //原来
      var className = changeFileNameToClassName(v.substring(3));//johnny修改后
      var importName=changeFirstChar(v.substring(3),false); //johnny修改后
      //if(className.toLowerCase()!=current) {//原来
      if(importName.toLowerCase() != current)//johnny修改后
      {
        //set.add('import "${changeFirstChar(className, false)}.dart"');//原来
        set.add('import "${changeFirstChar(importName, false)}.dart"');//johnny修改后
      }
      //return "List<${changeFirstChar(className)}>";//原来
      return "List<${className}>";//johnny修改后

    }else if(v.startsWith(TAG)){
      var fileName=changeFirstChar(v.substring(1),false);
      var className = changeFileNameToClassName(fileName);
      if(fileName.toLowerCase()!=current) {
        set.add('import "$fileName.dart"');//原来
        //set.add('import "$className.dart"');//johnny修改后
      }
      //return changeFirstChar(fileName);//原来
      return changeFirstChar(className);//johnny修改后
    }
    return "String";
  }else{
    return "String";
  }
 }

//替换模板占位符
String format(String fmt, List<Object> params) {
  int matchIndex = 0;
  String replace(Match m) {
    if (matchIndex < params.length) {
      switch (m[0]) {
        case "%s":
          return params[matchIndex++].toString();
      }
    } else {
      throw  Exception("Missing parameter for string format");
    }
    throw  Exception("Invalid format string: " + m[0].toString());
  }
  return fmt.replaceAllMapped("%s", replace);
}

void main(){
  walk();
}