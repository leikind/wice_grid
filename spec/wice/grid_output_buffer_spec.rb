describe Wice::GridOutputBuffer do
  FILTER_COMMON_CODE = 'here filter code'


  let(:buffer){Wice::GridOutputBuffer.new}

  it 'should to_s' do
    expect(buffer.to_s.class).to eq(ActiveSupport::SafeBuffer)
  end

  it 'should add_filter' do

    expect(buffer.add_filter('key', FILTER_COMMON_CODE)).to eq(FILTER_COMMON_CODE)
  end

  it 'should filter_for' do

    buffer.add_filter('key', FILTER_COMMON_CODE)
    expect(buffer.filter_for('key')).to eq(FILTER_COMMON_CODE)
  end

  it 'should filter_for 2 times' do
    buffer.add_filter('key', FILTER_COMMON_CODE)

    expect(buffer.filter_for('key')).to eq(FILTER_COMMON_CODE)
    expect { buffer.filter_for('key') }.to raise_error(Wice::WiceGridException)
  end

  it 'should filter_for without filters' do

    expect { buffer.filter_for('key') }.to raise_error(Wice::WiceGridException)
  end

  it 'should filter_for return empty string' do
    buffer.return_empty_strings_for_nonexistent_filters = true

    expect(buffer.filter_for('key')).to eq('')
  end
end
