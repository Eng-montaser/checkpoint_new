import 'package:checkpoint/model/UserData.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManger {
  Future<dynamic> saveData(CacheType cacheType, UserData data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString("pincode", '1111');
    switch (cacheType) {
      case CacheType.userData:
        if (data.token != null) await prefs.setString("token", data.token!);
        if (data.name != null) await prefs.setString("name", data.name!);
        if (data.email != null) await prefs.setString("email", data.email!);
        if (data.phone != null) await prefs.setString("phone", data.phone!);
        if (data.role_id != null) await prefs.setInt("role_id", data.role_id!);
        if (data.image != null) await prefs.setString("image", data.image!);
        if (data.id != null) await prefs.setInt("id", data.id!);
        if (data.shift_hours != null)
          await prefs.setString("shift_hours", data.shift_hours!);
        if (data.shift_start != null)
          await prefs.setString("shift_start", data.shift_start!);
        if (data.shift_end != null)
          await prefs.setString("shift_end", data.shift_end!);
        if (data.tall != null) await prefs.setString("tall", data.tall!);
        if (data.weight != null) await prefs.setString("weight", data.weight!);
        if (data.nationality != null)
          await prefs.setString("nationality", data.nationality!);
        if (data.pin_code != null)
          await prefs.setString("pin_code", '${data.pin_code}');
        if (data.designation != null)
          await prefs.setString("designation", data.designation!);
        if (data.device_id != null)
          await prefs.setString("device_id", data.device_id!);
        print("|||||||||||||");
        print(data.token);
        print(prefs.getString("token"));
        break;
      case CacheType.otherData:
        // TODO: Handle this case.
        break;
    }
  }

  Future<dynamic> getData(cacheType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data;
    switch (cacheType) {
      case CacheType.userData:
        UserData userData = new UserData(
          token: prefs.getString("token"),
          name: prefs.getString("name"),
          email: prefs.getString("email"),
          phone: prefs.getString("phone"),
          role_id: prefs.getInt("role_id"),
          image: prefs.getString("image"),
          nationality: prefs.getString("nationality"),
          weight: prefs.getString("weight"),
          tall: prefs.getString("tall"),
          pin_code: prefs.getString("pin_code").toString(),
          designation: prefs.getString("designation"),
          device_id: prefs.getString("device_id"),
          id: prefs.getInt("id"),
          shift_end: prefs.getString("shift_end"),
          shift_start: prefs.getString("shift_start"),
          shift_hours: prefs.getString("shift_hours"),
        );
        data = userData;
        break;
      case CacheType.otherData:
        // TODO: Handle this case.
        break;
    }
    return data;
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    return token;
  }

  Future<String?> getPinCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pin = prefs.getString("pin_code");
    return pin != null ? pin.toString() : null;
  }

  Future<bool?> getIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("is_login");
  }

  saveIsLogin(bool isLogin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_login", isLogin);
  }

  Future<dynamic> removeData(CacheType cacheType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (cacheType) {
      case CacheType.userData:
        await prefs.clear();
//        await prefs.remove("token");
//        await prefs.remove("name");
//        await prefs.remove("email");
//        await prefs.remove("phone");
//        await prefs.remove("role_id");
//        await prefs.remove("image");
//        await prefs.remove("nationality");
//        await prefs.remove("weight");
//        await prefs.remove("tall");
//        await prefs.remove("pin_code");
//        await prefs.remove("designation");
//        await prefs.remove("device_id");
        break;
      case CacheType.otherData:
        // TODO: Handle this case.
        break;
    }
  }
}

enum CacheType { userData, otherData }
