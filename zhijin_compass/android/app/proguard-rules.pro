# Flutter core rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.embedding.engine.systemchannels.** { *; }

# Native methods and additional rules
-keepclasseswithmembernames class ** {
    native <methods>;
}
-keepattributes Signature
-keep class sun.misc.Unsafe { *; }

# Taobao/Alibaba related rules
-keep class com.taobao.** {*;}
-keep class com.alibaba.** {*;}
-keep class com.alipay.** {*;}
-keep class com.ut.** {*;}
-keep class com.ta.** {*;}
-keep class anet.**{*;}
-keep class anetwork.**{*;}
-keep class org.android.spdy.**{*;}
-keep class org.android.agoo.**{*;}
-keep class android.os.**{*;}
-keep class org.json.**{*;}
# 保留阿里云推送SDK相关类
-keep class com.aliyun.ams.push.** { *; }
-keep class com.alibaba.sdk.android.push.** { *; }
-keep class com.taobao.accs.** { *; }
-keep class org.android.agoo.** { *; }

# 保留设备ID相关方法
-keepclassmembers class * {
    public java.lang.String getDeviceId();
}

# 保留所有实现Serializable接口的类
-keep class * implements java.io.Serializable { *; }

# Add missing dontwarn rules for Alibaba/Flutter components
-dontwarn com.alibaba.mtl.appmonitor.**
-dontwarn com.alibaba.wireless.security.open.**
-dontwarn com.google.android.play.core.**
-dontwarn com.taobao.alivfssdk.**
-dontwarn com.taobao.analysis.**
-dontwarn com.taobao.orange.**
-dontwarn com.taobao.tlog.adapter.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn com.taobao.**
-dontwarn com.alibaba.**
-dontwarn com.alipay.**
-dontwarn anet.**
-dontwarn org.android.spdy.**
-dontwarn org.android.agoo.**
-dontwarn anetwork.**
-dontwarn com.ut.**
-dontwarn com.ta.** 


# Add missing rules from R8
-dontwarn com.alibaba.wireless.security.open.SecurityGuardManager
-dontwarn com.alibaba.wireless.security.open.SecurityGuardParamContext
-dontwarn com.alibaba.wireless.security.open.securesignature.ISecureSignatureComponent
-dontwarn com.aliyun.ams.emas.push.data.NotificationDataManager
-dontwarn com.google.firebase.messaging.TopicOperation$TopicOperations
-dontwarn com.huawei.android.os.BuildEx$VERSION
-dontwarn com.huawei.android.telephony.ServiceStateEx
-dontwarn com.huawei.hianalytics.process.HiAnalyticsConfig$Builder
-dontwarn com.huawei.hianalytics.process.HiAnalyticsConfig
-dontwarn com.huawei.hianalytics.process.HiAnalyticsInstance$Builder
-dontwarn com.huawei.hianalytics.process.HiAnalyticsInstance
-dontwarn com.huawei.hianalytics.process.HiAnalyticsManager
-dontwarn com.huawei.hianalytics.util.HiAnalyticTools
-dontwarn com.huawei.libcore.io.ExternalStorageFile
-dontwarn com.huawei.libcore.io.ExternalStorageFileInputStream
-dontwarn com.huawei.libcore.io.ExternalStorageFileOutputStream
-dontwarn com.huawei.libcore.io.ExternalStorageRandomAccessFile
-dontwarn org.android.netutil.NetUtils
-dontwarn org.android.netutil.PingEntry
-dontwarn org.android.netutil.PingResponse
-dontwarn org.android.netutil.PingTask
-dontwarn org.bouncycastle.crypto.BlockCipher
-dontwarn org.bouncycastle.crypto.engines.AESEngine
-dontwarn org.bouncycastle.crypto.prng.SP800SecureRandom
-dontwarn org.bouncycastle.crypto.prng.SP800SecureRandomBuilder

# 保持Flutter Ali Auth相关类不被混淆
-keep class com.fluttercandies.flutter_ali_auth.** { *; }
-keep class com.mobile.auth.gatewayauth.** { *; }
-keep class * implements com.mobile.auth.gatewayauth.TokenResultListener { *; }
# OPPO通道
-keep public class * extends android.app.Service
# 小米通道
-keep class com.xiaomi.** {*;}
-dontwarn com.xiaomi.**
# 华为通道
-keep class com.huawei.** {*;}
-dontwarn com.huawei.**
# vivo通道
-keep class com.vivo.** {*;}
-dontwarn com.vivo.**
# OPPO通道
-keep public class * extends android.app.Service
# 友盟统计
-keep class com.umeng.** {*;}

-keep class org.repackage.** {*;}

-keep class com.uyumao.** { *; }

-keepclassmembers class * {
   public <init> (org.json.JSONObject);
}

-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keep public class [com.stock.zhijin_compass].R$*{
public static final int *;
}