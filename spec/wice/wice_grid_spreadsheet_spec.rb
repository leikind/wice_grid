describe Wice::Spreadsheet do
  subject(:spreadsheet){Wice::Spreadsheet.new('hello', ';')}

  describe '#<<(row)' do
    subject(:add_row) {spreadsheet << row}
    let(:row) {%w(hello world!)}

    it 'sends :<< to @csv' do
      expect(spreadsheet.instance_variable_get :@csv).to receive(:<<).with row
      add_row
    end
  end
end
