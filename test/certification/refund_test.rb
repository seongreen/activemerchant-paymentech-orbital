require 'test_helper'
require 'faster_csv'
require 'yaml'
require 'ruby-debug'
require 'active_merchant'

class RefundTest < Test::Unit::TestCase

  context "Refund Certification Test" do
    setup do
      @gateway = remote_gateway
    end

    teardown do
      FasterCSV.open('certification_refund.csv', "a+") do |csv|
        csv << [ 
                @request["Test ID"], @request["Ref Test ID"], @request["Card Type"], 
                @request["Amount"], "N/A",
                @response.resp_code, @response.approval_status, @response.tx_ref_num
               ]
      end

      File.open('refund.txt', "a+") do |text|
        text << @request["Test ID"] +"\n\n "+ 
          @gateway.request.xml + @gateway.response.doc.to_s + "\n\n"
      end
    end

    test_name = 'refund'
    
    file_path = File.join("test", "certification","fixtures", test_name+".yml")

    @test_cases = YAML.load_file(file_path)
    @test_cases["transactions"].each do |tra|
      
      test_id = tra["Test ID"]
     
      should "run #{test_name} Test ID #{test_id}" do        

        @request  = tra
        @response = @gateway.refund(tra["Amount"], {
                                      :order_id => tra["Test ID"],
                                      :tx_ref_num => tra["Tx Ref Num"]
                                    })
      end 
    end
  end
end
