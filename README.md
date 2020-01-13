本项目用于自动生成json serializable类的序列化和反序列化部分代码

技术获取来源：https://flutterchina.club/json/
            https://book.flutterchina.club/chapter11/json_model.html

本项目分为两部分，第一部分需要自己编写json内容对应的model类，只自动生成序列化和反序列化部分代码：

1、引用组件库，在项目根目录下的pubspec.yaml中添加以下代码：

dependencies:
  # Your other regular dependencies here
  json_annotation: ^2.0.0

dev_dependencies:
  # Your other dev_dependencies here
  build_runner: ^1.0.0
  json_serializable: ^2.0.0


2、在项目根目录下的models文件夹中新建model类，代码模版如下：

import 'package:json_annotation/json_annotation.dart';

// user.g.dart 的内容将在我们运行生成命令后自动生成
// 注意：这段代码必须放在@JsonSerializable() 的前面，否则生成会没有任何输出结果。
part 'user.g.dart';

///这个标注是告诉生成器，这个类是需要生成Model类的
@JsonSerializable()

class User{
  User(this.name, this.email);

  String name;
  String email;

  //不同的类使用不同的mixin即可
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}



3、打开终端，在项目根目录下执行：

flutter packages pub run build_runner build

//执行成功后，会自动生成user.g.dart文件，里面实现了User类的_$UserFromJson和_$UserToJson这两个方法。



到这里，自动生成json对应的类的序列化和反序列化部分代码就已经实现了。
但是每个json对应的类都必须手工编写，这个工作量也是非常的大。所以接下来第二部分是实现为json内容自动生成对应的model类。

1、引用组件库，在项目根目录下的pubspec.yaml中添加以下代码：

dependencies:
  # Your other regular dependencies here
  json_annotation: ^2.0.0

dev_dependencies:
  # Your other dev_dependencies here
  build_runner: ^1.0.0
  json_serializable: ^2.0.0

2、使用json_to_model_auto_generator的mo.dart可自动生成jsons中的json文件内容对应的model类。
  打开终端，然后将当前路径定位到：/lib/json_to_model_auto_generator/,然后执行命令：dart mo.dart
  运行mo.dart代码时，会根据template.txt模版为jsons文件夹中的所有json文件生成对应的model类，生成后的
  model类存放中models文件夹中。 例如：/lib/json_to_model_auto_generator/jsons 中的user.json文件，
  执行后会在/lib/json_to_model_auto_generator/models/ 里面出现user.dart文件。

3、打开终端，在项目根目录下执行：

flutter packages pub run build_runner build

//执行成功后，会自动生成user.g.dart文件，里面实现了User类的_$UserFromJson和_$UserToJson这两个方法。

