import
  unittest

import
  ../../../src/c3k/utils/path {.all.}


# unexpandTilde(path, homeDirPath, dirSep)
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
