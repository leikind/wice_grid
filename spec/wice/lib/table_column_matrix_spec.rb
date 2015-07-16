# encoding: utf-8
module Wice
  describe TableColumnMatrix do
    GENERAL_CONDITIONS = 'conditions'

    it 'should new' do
      table = TableColumnMatrix.new

      expect(table.class).to eq(TableColumnMatrix)
    end

    it 'should add_condition' do
      table = TableColumnMatrix.new
      table.add_condition('key', GENERAL_CONDITIONS)

      expect(table.conditions).to include(GENERAL_CONDITIONS)
    end

    it 'should set default_model_class' do
      table = TableColumnMatrix.new
      table.default_model_class = Dummy
    end
  end
end
