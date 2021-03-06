#encoding: utf-8
require_relative '../test_helper'

class TestAddress < Minitest::Test
  def test_address
    a = EmailAddress.new("User+tag@example.com")
    assert_equal "user+tag", a.local.to_s
    assert_equal "example.com", a.host.to_s
    assert_equal "us*****@ex*****", a.munge
    assert_equal :default, a.provider
  end

  # LOCAL
  def test_local
    a = EmailAddress.new("User+tag@example.com")
    assert_equal "user", a.mailbox
    assert_equal "user+tag", a.left
    assert_equal "tag", a.tag
  end

  # HOST
  def test_host
    a = EmailAddress.new("User+tag@example.com")
    assert_equal "example.com", a.hostname
    #assert_equal :default, a.provider
  end

  # ADDRESS
  def test_forms
    a = EmailAddress.new("User+tag@example.com")
    assert_equal "user+tag@example.com", a.to_s
    assert_equal "user@example.com", a.canonical
    assert_equal "{63a710569261a24b3766275b7000ce8d7b32e2f7}@example.com", a.redact
    assert_equal "{b58996c504c5638798eb6b511e6f49af}@example.com", a.redact(:md5)
    assert_equal "b58996c504c5638798eb6b511e6f49af", a.reference
  end

  # COMPARISON & MATCHING
  def test_compare
    a = ("User+tag@example.com")
    #e = EmailAddress.new("user@example.com")
    n = EmailAddress.new(a)
    c = EmailAddress.new_canonical(a)
    #r = EmailAddress.new_redacted(a)
    assert_equal true, n == "user+tag@example.com"
    assert_equal true, n >  "b@example.com"
    assert_equal true, n.same_as?(c)
    assert_equal true, n.same_as?(a)
  end

  def test_matches
    a = EmailAddress.new("User+tag@gmail.com")
    assert_equal false,  a.matches?('mail.com')
    assert_equal 'google',  a.matches?('google')
    assert_equal 'user+tag@',  a.matches?('user+tag@')
    assert_equal 'user*@gmail*',  a.matches?('user*@gmail*')
  end

  def test_empty_address
    a = EmailAddress.new("")
    assert_equal "{da39a3ee5e6b4b0d3255bfef95601890afd80709}", a.redact
    assert_equal "", a.to_s
    assert_equal "", a.canonical
    assert_equal "d41d8cd98f00b204e9800998ecf8427e", a.reference
  end

  # VALIDATION
  def test_valid
    assert EmailAddress.valid?("User+tag@example.com", dns_lookup: :a), "valid 1"
    assert ! EmailAddress.valid?("User%tag@example.com", dns_lookup: :a), "valid 2"
    assert EmailAddress.new("ɹᴉɐℲuǝll∀@ɹᴉɐℲuǝll∀.ws", local_encoding: :uncode, dns_lookup: :off ), "valid unicode"
  end

  def test_no_domain
    e = EmailAddress.new("User+tag.gmail.ws")
    assert_equal '', e.hostname
    assert_equal false, e.valid? # localhost not allowed by default
  end

  def test_regexen
    assert "First.Last+TAG@example.com".match(EmailAddress::Address::CONVENTIONAL_REGEX)
    assert "First.Last+TAG@example.com".match(EmailAddress::Address::STANDARD_REGEX)
    assert_equal nil, "First.Last+TAGexample.com".match(EmailAddress::Address::STANDARD_REGEX)
    assert_equal nil, "First#Last+TAGexample.com".match(EmailAddress::Address::CONVENTIONAL_REGEX)
    assert "aasdf-34-.z@example.com".match(EmailAddress::Address::RELAXED_REGEX)
  end

  # Quick Regression tests for addresses that should have been valid (but fixed)
  def test_issues
    assert true, EmailAddress.valid?('test@jiff.com', dns_lookup: :mx) # #7
    assert true, EmailAddress.valid?("w.-asdf-_@hotmail.com") # #8
    assert true, EmailAddress.valid?("first_last@hotmail.com") # #8
  end

end
