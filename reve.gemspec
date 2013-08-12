# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{reve}
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lisa Seelye"]
  s.date = %q{2012-02-05}
  s.email = %q{lisa@thedoh.com}
  s.extra_rdoc_files = [
    "ChangeLog"
  ]
  s.files = [
    "LICENSE",
     "Rakefile",
     "VERSION",
     "init.rb",
     "lib/reve.rb",
     "lib/reve/classes.rb",
     "lib/reve/exceptions.rb",
     "lib/reve/extensions.rb",
     "reve.rb",
     "tester.rb"
  ]
  s.homepage = %q{https://github.com/lisa/reve}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{reve}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Reve is a Ruby library to interface with the Eve Online API}
  s.test_files = [
    "test/test_reve.rb",
     "test/xml/account_status.xml",
     "test/xml/alliances.xml",
     "test/xml/assets.xml",
     "test/xml/badxml.xml",
     "test/xml/certificate_tree.xml",
     "test/xml/char_contacts.xml",
     "test/xml/char_facwarstats.xml",
     "test/xml/char_info.xml",
     "test/xml/char_info_full.xml",
     "test/xml/char_info_limited.xml",
     "test/xml/char_medals.xml",
     "test/xml/character_sheet.xml",
     "test/xml/characterid.xml",
     "test/xml/charactername.xml",
     "test/xml/characters.xml",
     "test/xml/conqurable_stations.xml",
     "test/xml/corp_contact.xml",
     "test/xml/corp_facwarstats.xml",
     "test/xml/corp_medals.xml",
     "test/xml/corp_member_medals.xml",
     "test/xml/corp_membersecurity.xml",
     "test/xml/corporate_assets_list.xml",
     "test/xml/corporate_assets_list_nesting.xml",
     "test/xml/corporate_market_orders.xml",
     "test/xml/corporate_wallet_balance.xml",
     "test/xml/corporate_wallet_journal.xml",
     "test/xml/corporate_wallet_transactions.xml",
     "test/xml/corporation_sheet.xml",
     "test/xml/errors/error_100.xml",
     "test/xml/errors/error_101.xml",
     "test/xml/errors/error_102.xml",
     "test/xml/errors/error_103.xml",
     "test/xml/errors/error_104.xml",
     "test/xml/errors/error_105.xml",
     "test/xml/errors/error_106.xml",
     "test/xml/errors/error_107.xml",
     "test/xml/errors/error_108.xml",
     "test/xml/errors/error_109.xml",
     "test/xml/errors/error_110.xml",
     "test/xml/errors/error_111.xml",
     "test/xml/errors/error_112.xml",
     "test/xml/errors/error_113.xml",
     "test/xml/errors/error_114.xml",
     "test/xml/errors/error_115.xml",
     "test/xml/errors/error_116.xml",
     "test/xml/errors/error_117.xml",
     "test/xml/errors/error_118.xml",
     "test/xml/errors/error_119.xml",
     "test/xml/errors/error_120.xml",
     "test/xml/errors/error_121.xml",
     "test/xml/errors/error_122.xml",
     "test/xml/errors/error_123.xml",
     "test/xml/errors/error_124.xml",
     "test/xml/errors/error_125.xml",
     "test/xml/errors/error_200.xml",
     "test/xml/errors/error_201.xml",
     "test/xml/errors/error_202.xml",
     "test/xml/errors/error_203.xml",
     "test/xml/errors/error_204.xml",
     "test/xml/errors/error_205.xml",
     "test/xml/errors/error_206.xml",
     "test/xml/errors/error_207.xml",
     "test/xml/errors/error_208.xml",
     "test/xml/errors/error_209.xml",
     "test/xml/errors/error_210.xml",
     "test/xml/errors/error_211.xml",
     "test/xml/errors/error_212.xml",
     "test/xml/errors/error_213.xml",
     "test/xml/errors/error_214.xml",
     "test/xml/errors/error_500.xml",
     "test/xml/errors/error_501.xml",
     "test/xml/errors/error_502.xml",
     "test/xml/errors/error_503.xml",
     "test/xml/errors/error_504.xml",
     "test/xml/errors/error_505.xml",
     "test/xml/errors/error_506.xml",
     "test/xml/errors/error_507.xml",
     "test/xml/errors/error_508.xml",
     "test/xml/errors/error_509.xml",
     "test/xml/errors/error_510.xml",
     "test/xml/errors/error_511.xml",
     "test/xml/errors/error_512.xml",
     "test/xml/errors/error_513.xml",
     "test/xml/errors/error_514.xml",
     "test/xml/errors/error_515.xml",
     "test/xml/errors/error_516.xml",
     "test/xml/errors/error_517.xml",
     "test/xml/errors/error_518.xml",
     "test/xml/errors/error_519.xml",
     "test/xml/errors/error_520.xml",
     "test/xml/errors/error_521.xml",
     "test/xml/errors/error_522.xml",
     "test/xml/errors/error_523.xml",
     "test/xml/errors/error_524.xml",
     "test/xml/errors/error_525.xml",
     "test/xml/errors/error_900.xml",
     "test/xml/errors/error_901.xml",
     "test/xml/errors/error_902.xml",
     "test/xml/errors/error_903.xml",
     "test/xml/errors/error_999.xml",
     "test/xml/errors.xml",
     "test/xml/eve_facwarstats.xml",
     "test/xml/eve_facwartopstats.xml",
     "test/xml/industryjobs.xml",
     "test/xml/kills.xml",
     "test/xml/mail_messages.xml",
     "test/xml/mailing_lists.xml",
     "test/xml/map_facwarsystems.xml",
     "test/xml/mapjumps.xml",
     "test/xml/mapkills.xml",
     "test/xml/market_transactions.xml",
     "test/xml/marketorders.xml",
     "test/xml/member_tracking.xml",
     "test/xml/nonmember_corpsheet.xml",
     "test/xml/notifications.xml",
     "test/xml/reftypes.xml",
     "test/xml/research.xml",
     "test/xml/server_status.xml",
     "test/xml/skill_in_training-amarr-titan.xml",
     "test/xml/skill_in_training-none.xml",
     "test/xml/skill_queue-paused.xml",
     "test/xml/skill_queue.xml",
     "test/xml/skilltree.xml",
     "test/xml/sovereignty.xml",
     "test/xml/starbase_fuel.xml",
     "test/xml/starbases.xml",
     "test/xml/wallet_balance.xml",
     "test/xml/wallet_journal.xml"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpricot>, [">= 0.6"])
    else
      s.add_dependency(%q<hpricot>, [">= 0.6"])
    end
  else
    s.add_dependency(%q<hpricot>, [">= 0.6"])
  end
end
