require 'happymapper'

module Cluster
  module Mpispec
    class Assertion
      include HappyMapper
      tag 'ASSERTION'
      element :result, String, tag: 'RESULT'
      element :message, String, tag: 'MESSAGE'
    end

    class It
      include HappyMapper
      tag 'IT'
      element :description, String, tag: 'DESCRIPTION'
      has_many :assertion, Assertion
    end

    class Describe
      include HappyMapper
      tag 'DESCRIBE'
      element :description, String, tag: 'DESCRIPTION'
      has_many :it, It
      has_many :describe, Describe
    end

    class Behaviour
      include HappyMapper
      tag 'BEHAVIOUR'
      has_many :describe, Describe
    end
  end
end
