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

      expect(table.class).to eq(TableColumnMatrix)
    end

    it 'should get column' do
      table = TableColumnMatrix.new
      table.default_model_class = Dummy

      expect(Dummy.columns).to include(table.get_column_by_model_class_and_column_name(Dummy, :name))
      expect(Dummy.columns).to include(table.get_column_in_default_model_class_by_column_name(:name))
    end

    it 'should get column not initialized' do
      table = TableColumnMatrix.new
      expect { table.get_column_in_default_model_class_by_column_name(:name) }.to raise_error
    end
  end
end
