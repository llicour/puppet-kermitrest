Facter.add('paxversion') do
  setcode do
    paxroot=Dir.glob('/usr/lib/ruby/gems/*/gems/passenger-*').last
    paxroot.kind_of?(String) ? paxroot.scan(/passenger-(.*)/).flatten.to_s : nil
  end
end
