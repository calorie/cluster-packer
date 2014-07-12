class XmlParser
  def self.parse(dir)
    results = []
    Dir.glob(File.join(dir, '*.xml')).each do |file|
      next unless valid_xml?(file)
      xml = File.read(file)
      xml_obj = Mpispec::Behaviour.parse(xml)
      next unless xml_obj.respond_to?(:describe)
      results << pass_tests?(xml_obj.describe)
    end
    pass_all?(results)
  end

  private

  def self.pass_tests?(describe)
    describe.each do |d|
      next unless d.respond_to?(:it)
      d.it.each do |i|
        next unless i.respond_to?(:assertion)
        i.assertion.each do |a|
          return false unless a.result == 'OK'
        end
      end
      if d.respond_to?(:describe)
        return false unless pass_tests?(d.describe)
      end
    end
    true
  end

  def self.pass_all?(results = [])
    return false if results.empty?
    !results.include?(false)
  end

  def self.valid_xml?(file)
    File.basename(file) =~ /\Arank\d+_output\.xml\z/
  end
end
