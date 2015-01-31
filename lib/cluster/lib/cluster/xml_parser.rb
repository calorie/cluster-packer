module Cluster
  class XmlParser
    def self.parse(dir)
      file = File.join(dir, 'output.xml')
      return false unless File.exist(file)
      xml = File.read(file)
      xml_obj = Mpispec::Behaviour.parse(xml)
      return false unless xml_obj.respond_to?(:describe)
      pass_tests?(xml_obj.describe)
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
  end
end
