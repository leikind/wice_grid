# encoding: utf-8
module Wice
  describe Spreadsheet do
    it 'should initialize' do
      spread = Spreadsheet.new('hello', ';')

      expect(spread.class).to eq(Wice::Spreadsheet)
    end

    it 'should add_row' do
      spread = Spreadsheet.new('hello', ';')
      spread << %w(hello world!)
    end
  end
end
