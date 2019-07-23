require 'spec_helper'

describe Minfraud::Response do
  let(:ok_response_double) do
    double(Net::HTTPOK, body: 'firstKey=first value;second_keyName=second value')
  end
  let(:warning_response_double) do
    double(Net::HTTPOK, body: 'err=COUNTRY_NOT_FOUND')
  end
  let(:error_response_double) do
    double(Net::HTTPOK, body: 'err=INVALID_LICENSE_KEY')
  end
  let(:server_error_response) do
    double(Net::HTTPServiceUnavailable)
  end
  let(:err) { Faker::HipsterIpsum.word }

  before do
    allow(ok_response_double).to receive(:is_a?).
      with(Net::HTTPSuccess).
      and_return(true)

    allow(warning_response_double).to receive(:is_a?).
      with(Net::HTTPSuccess).
      and_return(true)

    allow(error_response_double).to receive(:is_a?).
      with(Net::HTTPSuccess).
      and_return(true)

    allow(server_error_response).to receive(:is_a?).
      with(Net::HTTPSuccess).
      and_return(false)
    allow(server_error_response).to receive(:is_a?).
      with(Net::HTTPServerError).
      and_return(true)
  end

  describe '.new' do
    subject(:response) { Minfraud::Response.new(ok_response_double) }

    it 'raises exception without an OK response' do
      expect { Minfraud::Response.new(server_error_response) }.
        to raise_exception(Minfraud::ServerError)
    end

    it 'raises exception if minFraud returns an error' do
      expect { Minfraud::Response.new(error_response_double) }.
        to raise_exception(Minfraud::ResponseError, /INVALID_LICENSE_KEY/)
    end

    it 'does not raise an exception if minFraud returns a warning' do
      expect { Minfraud::Response.new(warning_response_double) }.not_to raise_exception
    end

    it 'turns raw body keys and values into attributes on the object' do
      expect(response.first_key).to eq('first value')
      expect(response.second_key_name).to eq('second value')
    end
  end

end
