class loginUserExceptions {
  final String message;

  const loginUserExceptions([this.message = "An error occurred while logging in"]);

  factory loginUserExceptions.code(String code) {
    switch (code) {
      case "weak-password":
        return const loginUserExceptions("The password provided is too weak.");
      case "email-already-in-use":
        return const loginUserExceptions("The account already exists for that email.");
      case "invalid-email":
        return const loginUserExceptions("The email address is badly formatted.");
      case "operation-not-allowed":
        return const loginUserExceptions("Email & Password accounts are not enabled.");
      case "user-disabled":
        return const loginUserExceptions("The user corresponding to the given email has been disabled.");
      case "user-not-found":
        return const loginUserExceptions("No user found for that email.");
      case "wrong-password":
        return const loginUserExceptions("Wrong password provided for that user.");
      case "invalid-verification-code":
        return const loginUserExceptions("The verification code is invalid.");
      case "invalid-verification-id":
        return const loginUserExceptions("The verification ID is invalid.");
      case "quota-exceeded":
        return const loginUserExceptions("Quota exceeded. Please try again later.");
      case "email-already-exists":
        return const loginUserExceptions("The email address is already in use by another account.");
      case "provider-already-linked":
        return const loginUserExceptions("The account is already linked with another provider.");
      case "requires-recent-login":
        return const loginUserExceptions("This operation is sensitive and requires recent authentication. Log in again before retrying.");
      case "credential-already-in-use":
        return const loginUserExceptions("This credential is already associated with a different user account.");
      case "user-mismatch":
        return const loginUserExceptions("The supplied credentials do not correspond to the previously signed in user.");
      case "account-exists-with-different-credential":
        return const loginUserExceptions("An account already exists with the same email address but different sign-in credentials.");
      case "network-request-failed":
        return const loginUserExceptions("A network error occurred. Please check your connection and try again.");
      case "too-many-requests":
        return const loginUserExceptions("We have blocked all requests from this device due to unusual activity. Try again later.");
      default:
        return const loginUserExceptions();
    }
  }
}