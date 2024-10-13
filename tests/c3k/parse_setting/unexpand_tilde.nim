import
  unittest

import
  ../../../src/c3k/parse_setting {.all.}


check unexpandTilde("/home/user", "/home/user/", '/') == "~/"
check unexpandTilde("/home/user/", "/home/user/", '/') == "~/"
check unexpandTilde("/home/user/home/user", "/home/user/", '/') == "~/home/user"
check unexpandTilde("/home/user/home/user/", "/home/user/", '/') == "~/home/user/"
check unexpandTilde(" /home/user", "/home/user/", '/') == " /home/user"
check unexpandTilde(" /home/user/", "/home/user/", '/') == " /home/user/"
check unexpandTilde("/home/user", "", '/') == "/home/user"
check unexpandTilde("/home/user/", "", '/') == "/home/user/"
check unexpandTilde("foo/home/user", "/home/user/", '/') == "foo/home/user"
check unexpandTilde("foo/home/user/", "/home/user/", '/') == "foo/home/user/"
