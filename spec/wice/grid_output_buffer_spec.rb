describe Wice::GridOutputBuffer do
  subject(:buffer){Wice::GridOutputBuffer.new}
  let(:key) {'key'}
  let(:filter_code) {'here filter code'}
  describe '#to_s' do
    subject(:method_to_s) {buffer.to_s}

    it 'has class ActiveSupport::SafeBuffer' do
      is_expected.to be_an ActiveSupport::SafeBuffer
    end
  end

  describe '#add_filter(key, filter_code)' do
    subject(:add_filter) {buffer.add_filter key, filter_code}

    it 'returns filter_code' do
      is_expected.to be filter_code
    end
  end
  describe '#filter_for(key)' do
    subject(:filter_for) {buffer.filter_for key}
    before do
      buffer.return_empty_strings_for_nonexistent_filters = false
    end

    context 'when #add_filter has been called with the key' do
      before do
        buffer.add_filter(key, filter_code)
      end

      it 'returns the code saved under the key' do
        is_expected.to be filter_code
      end

      it 'removes the code and railses Wice::WiceGridException when called again' do
        buffer.filter_for key
        expect { filter_for }.to raise_error Wice::WiceGridException
      end
    end

    context 'when #add_filter has not been called with the key' do
      it 'railses Wice::WiceGridException' do
        expect { filter_for }.to raise_error Wice::WiceGridException
      end

      context 'when #return_empty_strings_for_nonexistent_filters is set to true' do
        before do
          buffer.return_empty_strings_for_nonexistent_filters = true
        end

        it 'returns empty string' do
          is_expected.to eq ''
        end
      end
    end
  end
end
