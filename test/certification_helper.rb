require 'test_helper'
require 'faster_csv'
require 'yaml'

class Test::Unit::CertificationsTestCase
  @@csv = nil
  @@order_id = 0

  def setup
    @certification_file = "certification_result.csv"

    unless @@csv
      @@csv = FasterCSV.open(@certification_file, "w")
    end

    @@order_id = @@order_id + 1
  end

  def teardown
    @@csv << @gateway.to_a
  end
end
