//package com.hiennv.flutter_callkit_incoming;
//
//import org.json.JSONArray;
//import org.json.JSONException;
//import org.json.JSONObject;
//
//import java.io.BufferedReader;
//import java.io.IOException;
//import java.io.InputStreamReader;
//import java.io.OutputStreamWriter;
//import java.net.HttpURLConnection;
//import java.net.MalformedURLException;
//import java.net.URL;
//
//public class FCMCall {
//
//try {
//        val mapdata =
//        data.getSerializable(EXTRA_CALLKIT_EXTRA) as HashMap<String, Any?>
//        System.out.println(mapdata["fcmtoken"]!!)
//        mapdata["fcmtoken"]?.let {
//        FCMCall().send(it as String)
//        }
//        } catch (e: Exception) {
//    }
//
//    public void send(final String token){
//        new Thread(new Runnable() {
//            @Override
//            public void run() {
//                sendFCMNotification(token);
//            }
//        }).start();
//    }
//    static void sendFCMNotification(String fcmToken) {
//        try {
//            URL url = new URL("https://fcm.googleapis.com/fcm/send");
//            HttpURLConnection conn;
//            conn = (HttpURLConnection) url.openConnection();
//            conn.setUseCaches(false);
//            conn.setDoInput(true);
//            conn.setDoOutput(true);
//            conn.setRequestMethod("POST");
//            conn.setRequestProperty("Authorization", "key=AAAAG8bzeow:APA91bEQai_ldUEZoR-i2WWNqPhjycgkH93YSE90pjKBF2LjjT6HrgtRfbTxvMh0wPsTWMquzBRHp29BX8iPykTbeMYThG4r7SVzQwGsRuVd0rOhyJsrB593XsKopDdVEjIdqyEuESxT");
//            conn.setRequestProperty("Content-Type", "application/json");
//            JSONObject infoJson = new JSONObject();
//            infoJson.put("type", "cut");
//            infoJson.put("channelKey", "cut");
//            JSONObject json = new JSONObject();
//            json.put("registration_ids", new JSONArray().put(fcmToken));
//            json.put("data", infoJson);
//            json.put("type", "cut");
//            json.put("notification", new JSONObject());
//            json.put("ttl", "30s");
//            OutputStreamWriter wr = new OutputStreamWriter(conn.getOutputStream());
//            wr.write(json.toString());
//            wr.flush();
//            int status = 0;
//
//            status = conn.getResponseCode();
//
//            if (status == 200) {
//                BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
//                System.out.println("Android Notification Response : " + reader.readLine());
//            } else if (status == 401) {
////client side error
//                System.out.println("Notification Response : TokenId : " + fcmToken + " Error occurred :");
//            } else if (status == 501) {
////server side error
//                System.out.println("Notification Response : [ errorCode=ServerError ] TokenId : " + fcmToken);
//            } else if (status == 503) {
////server side error
//                System.out.println("Notification Response : FCM Service is Unavailable  TokenId : " + fcmToken);
//            }
//        } catch (MalformedURLException mlfexception) {
//// Prototcal Error
//            System.out.println("Error occurred while sending push Notification!.." + mlfexception.getMessage());
//        } catch (IOException mlfexception) {
////URL problem
//            System.out.println("Reading URL, Error occurred while sending push Notification!.." + mlfexception.getMessage());
//        } catch (JSONException jsonexception) {
////Message format error
//            System.out.println("Message Format, Error occurred while sending push Notification!.." + jsonexception.getMessage());
//        } catch (Exception exception) {
//
////General Error or exception.
//
//            System.out.println("Error occurred while sending push Notification!.." + exception.getMessage());
//
//        }
//
//    }
//
//
//}
