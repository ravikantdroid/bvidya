// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// final FirebaseAuth _auth = FirebaseAuth.instance;
// final GoogleSignIn googleSignIn = GoogleSignIn();

// String name;
// String email;
// String imageUrl;

// Future<String> signInWithGoogle() async {
//   final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
//   final GoogleSignInAuthentication googleSignInAuthentication =
//   await googleSignInAccount.authentication;

//   final AuthCredential credential = GoogleAuthProvider.credential(
//     accessToken: googleSignInAuthentication.accessToken,
//     idToken: googleSignInAuthentication.idToken,
//   );

//   final UserCredential  authResult = await _auth.signInWithCredential(credential);
//   final User user = authResult.user;

//   assert(user.email != null);
//   assert(user.displayName != null);
//   assert(user.photoURL != null);

//   name = user.displayName;
//   email = user.email;
//   imageUrl = user.photoURL;

//   if (name.contains(" ")) {
//     name = name.substring(0, name.indexOf(" "));
//   }

//   assert(!user.isAnonymous);
//   assert(await user.getIdToken() != null);

//   final User currentUser = await _auth.currentUser;
//   assert(user.uid == currentUser.uid);

//   return 'Successfully loggedin: $user';
// }

// void signOutGoogle() async {
//   await googleSignIn.signOut();
// }