
class ApiConstat {
  static const String baseUrl = "http://localhost:3001/api/v1";
}

class EndPoints {
  static const String signIn = "/auth/sign-in/email";
  // static const String offers = 'api/offers';
  // static const String profile = '/api/profile';
  // static const String logout = '/api/auth/logout';

  //  ------------Psw EndPoind----------------
  static const String signUp = "/auth/sign-up/email";



  static String caregetApplicationsByOffer(String offerId,) =>
      "/api/applications/$offerId";
  static const String careHomeAcceptApplication = 'api/applications/accept';
  static const String careHomeRejectApplication = 'api/applications/reject';
  static const String careHomeApplications = 'api/applications';


  // -------------Admin EndPoind----------------

  static const String verifyAdminPending = '/api/admin/users/PSW';

  static String verifyAdminApprove(String pswId) =>
      'api/admin/verifications/$pswId/approve';

  static String verifyAdminReject(String pswId) =>
      'api/admin/verifications/$pswId/reject';
  static const String adminApplicationPsw = 'api/admin/applications';

  static String AdminapproveApplication(String requestId) =>
      "api/admin/applications/$requestId/approve";

  static String AdminrejectApplication(String requestId) =>
      "api/admin/applications/$requestId/reject";
  static String adminGetAllOffers = 'api/admin/offers';

  static String adminCancelOffer(String offerId) => 'api/admin/offers/$offerId';

  // PSW Profile
  static String adminPswProfile(String id) => 'api/admin/users/profile?id=$id';


}