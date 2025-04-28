######################################################################
# This file contains product-specific overrides for the SDx product
# for the entries in common.msg. Each entry in this file must contain
# the key and gid entries, which must match the corresponding
# entry in the original .msg file. Format, description, and resolution
# entries are optional, and can be used to make the messaging
# behavior product-specific.
######################################################################
messages =
(
  {
    format = "Message '!%1!' appears !%2! times and further instances of the messages will be disabled.\n";
    gid = "17-14";
    id = "14";
    key = "Message '%s' appears more than %d times and has been disabled. User can change this message limit to see more message instances.\n";

  }
  
);
version = "4";
