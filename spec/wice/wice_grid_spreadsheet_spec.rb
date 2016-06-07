describe Wice::Spreadsheet do
  let(:spreadsheet){Wice::Spreadsheet.new('hello', ';')}

  it 'should initialize' do

    expect(spreadsheet.class).to eq(Wice::Spreadsheet)
  end

  it 'should add_row' do
    spreadsheet << %w(hello world!)
  end
end
