// THIS FILE WAS GENERATED BY `xtp-cpp-bindgen`. DO NOT EDIT.
#include <chrono>
#include <cstddef>
#include <expected>
#include <jsoncons/json.hpp>
#include <memory>
#include <span>
#include <stdint.h>
#include <string>
#include <string_view>
#include <vector>

namespace pdk {

// the incoming email
struct IncomingEmail {
  // to, from, subject, etc
  jsoncons::json headers;
  // body of email
  std::string body;
  // to
  std::string receiver;
  // from
  std::string sender;
};

// the incoming email
struct ReplyEmail {
  // body of email
  std::string body;
  // email subject
  std::string subject;
};

// host function errors
enum class Error { extism, host_null, not_json, json_null, not_implemented };

/**
 * send it to the inbox, may only be called once
 *
 * @param input the incoming email
 * @return sendmail return code
 */
std::expected<int32_t, Error> deliver(const IncomingEmail &input);

/**
 * reply back, may only be called once
 *
 * @param input the incoming email
 * @return sendmail return code
 */
std::expected<int32_t, Error> reply(const ReplyEmail &input);

} // namespace pdk

namespace impl {

/**
 * This function takes a IncomingEmail. What you do with it is up
 * to you.
 *
 * @param input the incoming email
 * @return sendmail return code, set to non-zero to bounce
 */
std::expected<int32_t, pdk::Error> onEmail(pdk::IncomingEmail &&input);

} // namespace impl