#include "extism-pdk.hpp"
#include "pdk.gen.hpp"

static int32_t get_result(std::string &subject, unsigned deliver_or_reply) {
  int32_t result = 0;
  if (subject.size() == sizeof("simulation00") - 1 &&
      subject.starts_with("simulation") &&
      (subject.at(subject.size() - 2) == '0' ||
       subject.at(subject.size() - 2) == '1') &&
      (subject.at(subject.size() - 1) == '0' ||
       subject.at(subject.size() - 1) == '1')) {
    result = subject.at(subject.size() - 2 + deliver_or_reply) - 48;
  }
  return result;
}

/**
 * send it to the inbox, may only be called once
 *
 * @param input the incoming email
 * @return sendmail return code
 */
std::expected<int32_t, pdk::Error> impl::deliver(pdk::IncomingEmail &&input) {
  int32_t result = 0;
  if (input.headers.contains("Subject")) {
    auto subject = input.headers["Subject"].as<std::string>();
    result = get_result(subject, 0);
  }
  extism::log_error(std::string("Faking delivery ") +
                    (result ? "FAILURE" : "SUCCESS"));
  return result;
}

/**
 * reply back, may only be called once
 *
 * @param input the incoming email
 * @return sendmail return code
 */
std::expected<int32_t, pdk::Error> impl::reply(pdk::ReplyEmail &&input) {
  int32_t result = get_result(input.subject, 1);
  extism::log_error(std::string("Faking reply ") +
                    (result ? "FAILURE" : "SUCCESS"));
  return result;
}
