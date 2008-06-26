class VimSnippet
    attr_accessor :code, :name

    def initialize(args={})
        @code   = args[:code]
        @name   = args[:name]
    end

    def parse
        @code.gsub!(/"/,'\"')
        if !@code.empty?
            @code = @code.gsub(/<(.*?)?>/) do |m|
                if $1.empty?
                    '".st.et."'
                else
                    "\".st.\"#{$1}\".et.\""
                end
            end
            @code = @code.gsub(/\n/, "<CR>").gsub("\t", "<Tab>")
            @code.gsub(/et."$/,'et')
        end
    end

    def out
puts(<<EOS)
exec "Snippet #{@name} #{self.parse}".st.et
EOS
    end
end

if $0 == __FILE__
require 'test/unit'
class TestVimSnippet < Test::Unit::TestCase

    def helper_vim_snippet(args={})
        VimSnippet.new(args)
    end
    
    def test_name_and_code
        s = helper_vim_snippet(:name => "pl", :code => "ble")
        assert_equal s.name, "pl", "test name"
        assert_equal s.code, "ble", "test snippet"
    end

    def test_simple_parse # lol :]
        s = helper_vim_snippet(:name => "pl", :code => "ble")
        assert_equal "ble", s.parse
    end

    def test_simple_parse2
        s = helper_vim_snippet(:name => "dupa", :code => "xxx <> hmm")
        assert_equal 'xxx ".st.et." hmm', s.parse
    end

    def test_simple_parse3
        s = helper_vim_snippet(:name => "dupa", :code => "xxx <ble> hmm")
        assert_equal 'xxx ".st."ble".et." hmm', s.parse
    end

    def test_simple_parse3
        s = helper_vim_snippet(:name => "dupa", :code => "xxx <> hmm dupa <>")
        assert_equal 'xxx ".st.et." hmm dupa ".st.et', s.parse
    end

    def test_quote
        s = helper_vim_snippet(:name => "dupa", :code => 'puts "<>"')
        assert_equal 'puts \"".st.et."\"', s.parse
    end

    def test_CR
        s = helper_vim_snippet(:name => "dupa", :code => "xxx\n\n<>")
        assert_equal 'xxx<CR><CR>".st.et', s.parse
    end

    def test_Tab
        s = helper_vim_snippet(:name => "dupa", :code => "xxx\t\t<>")
        assert_equal 'xxx<Tab><Tab>".st.et', s.parse
    end

    def test_CR_and_Tab_super_mix_lol
        s = helper_vim_snippet(:name => "dupa", :code => "\nxxx\t\n\t<>\n")
        assert_equal '<CR>xxx<Tab><CR><Tab>".st.et."<CR>', s.parse
    end

    # exec "Snippet xif ".st."expression".et." if ".st."condition".et.";".st.et
    def test_xif
        s = helper_vim_snippet(:name => "xif", 
            :code => "<expression> if <condition>;<>")
        assert_equal '".st."expression".et." if ".st."condition".et.";".st.et', s.parse
    end

    # exec "Snippet sub sub ".st."FunctionName".et." {<CR>".st.et."<CR>}<CR>".st.et
    def test_sub_parse_CR_and_Tab
        s = helper_vim_snippet(:name => "sub", 
            :code => "sub <FunctionName> {\n<>\n}")
        assert_equal 'sub ".st."FunctionName".et." {<CR>".st.et."<CR>}', s.parse
    end

    # exec "Snippet ifee if (".st.et.") {<CR>".st."2".et."<CR>} elsif (".st.et.") {<CR>".st.et."<CR>} else {<CR>".st.et."}<CR>}<CR>".st.et
    def test_ifee
        s = helper_vim_snippet(:name => "ifee", 
           :code => "if (<>) {\n<2>\n} elsif (<>) {\n<>\n} else {\n<>\n}\n<>")
        assert_equal 'if (".st.et.") {<CR>".st."2".et."<CR>} elsif (".st.et.") {<CR>".st.et."<CR>} else {<CR>".st.et."<CR>}<CR>".st.et', s.parse
    end
end

end # end of if $0 === __FILE__
