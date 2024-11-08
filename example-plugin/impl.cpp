#include "pdk.gen.hpp"

/**
 * This function takes a IncomingEmail. What you do with it is up
 * to you.
 *
 * @param input the incoming email
 * @return sendmail return code, set to non-zero to bounce
 */
std::expected<int32_t, pdk::Error> impl::onEmail(pdk::IncomingEmail &&input) {
  auto res = pdk::deliver(input);
  if (res && *res == 0) {
    std::string subject = input.headers.contains("Subject")
                              ? input.headers["Subject"].as<std::string>()
                              : "";
    if (subject.contains("Project XYZ") || input.body.contains("Project XYZ")) {
      pdk::ReplyEmail response;
      response.subject = "RE: " + subject;
      response.body =
          "Talking about Project XYZ is forbidden!!!\n\nPlease stop talking "
          "about Project XYZ!";
      res = pdk::reply(response);
    }
  }
  return res;
}
