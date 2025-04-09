@[Link(ldflags: "-L#{__DIR__}/../ext/")]
@[Link(ldflags: "#{__DIR__}/../ext/libctags.a")]

lib libctags
end

module Ctags
end