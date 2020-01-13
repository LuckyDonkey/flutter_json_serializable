import 'package:json_annotation/json_annotation.dart';


part 'shop.g.dart';
@JsonSerializable()
class Shop {
    Shop();

    String title;
    String url;
    
    factory Shop.fromJson(Map<String,dynamic> json) => _$ShopFromJson(json);
    Map<String, dynamic> toJson() => _$ShopToJson(this);

    
}