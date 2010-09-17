require 'test_helper'
require 'faster_csv'
require 'yaml'
require 'ruby-debug'
require 'active_merchant'

class PurchaseTest < Test::Unit::TestCase

  context "Purchase Certification Test" do
    setup do
      @gateway = remote_gateway
    end

    teardown do
      FasterCSV.open('certification_purchase.csv', "a+") do |csv|
        csv << [ 
                @request["Test ID"], @request["Card Type"], @request["AVS Zip"], 
                @request["CVD"], @request["Amount"], 
                @response.auth_code, @response.resp_code, @response.avs_resp_code, 
                @response.cvv2_resp_code, @response.tx_ref_num
               ]
      end

      File.open('purchase_test.txt', "a+") do |text|
        text << @request["Test ID"] +"\n\n "+ 
          @gateway.request.xml + @gateway.response.doc.to_s + "\n\n"
      end
    end

    test_name = 'purchase'
    
    file_path = File.join("test", "certification","fixtures", test_name+".yml")

    @test_cases = YAML.load_file(file_path)
    
    @test_cases["transactions"].each do |tra|
      
      test_id = tra["Test ID"]
     
      should "run #{test_name} Test ID #{test_id}" do        
        credit_card = ActiveMerchant::Billing::CreditCard.new(
                                   :last_name          => 'Doe', 
                                   :number             => tra["Card Number"], 
                                   :verification_value => tra["CVD"],
                                   :month              => '12', 
                                   :year               => '12'
                                   )
        @request  = tra
        @response = @gateway.purchase(
                                       tra["Amount"], 
                                       credit_card, 
                                       {
                                         :order_id => tra["Test ID"],
                                         :address  => {:zip =>tra["AVS Zip"]},
                                         :card_sec_val_ind => tra["Card Type"] =~ /(?:Visa|DS)/ ? '1' : nil                                         
                                       })
      end 
    end
  end
end
