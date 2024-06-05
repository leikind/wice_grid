describe Wice::TableColumnMatrix do
  subject(:table) {Wice::TableColumnMatrix.new}
  let(:conditions) {'general_conditions'}
  let(:column) {'key'}
  let(:model) {Dummy}
  let(:column_name) {:name}

  describe '#add_condition(column, conditions)' do
    subject(:add_condition) {table.add_condition column, conditions}

    it 'adds the pair column, conditions to #generated_conditions' do
      expect{add_condition}.to change(table.generated_conditions, :size).by 1
      expect(table.generated_conditions.last).to eq [column, conditions]
    end

    it 'adds conditions to #conditions' do
      expect(table.conditions).to eq []
      add_condition
      expect(table.conditions).to eq [conditions]
    end
  end

  describe 'default_model_class=(model)' do
    subject(:set_default_model_class) {table.default_model_class = model}

    it 'assingns model to #default_model_class' do
      expect{set_default_model_class}.to change(table, :default_model_class).to model
    end

    it 'calls #init_columns_of_table with model' do
      expect(table).to receive(:init_columns_of_table).with model
      set_default_model_class
    end
  end

  describe '#get_column_by_model_class_and_column_name(model_class, column_name)' do
    before do
      table.default_model_class = model
    end

    subject(:get_column_by_model_class_and_column_name) do
      table.get_column_by_model_class_and_column_name model, column_name
    end

    it 'returns an instace of ActiveRecord::ConnectionAdapters::Column' do
      is_expected.to be_an ActiveRecord::ConnectionAdapters::Column
    end
  end

  describe '#get_column_in_default_model_class_by_column_name(column_name)' do
    subject(:get_column_in_default_model_class_by_column_name) do
      table.get_column_in_default_model_class_by_column_name column_name
    end

    context 'when #default_model_class is defined' do
      before do
        table.default_model_class = model
      end

      it 'returns an instace of ActiveRecord::ConnectionAdapters::Column' do
        is_expected.to be_an ActiveRecord::ConnectionAdapters::Column
      end
    end

    context 'when #default_model_class is undefined' do
      it 'raises Wice::WiceGridException' do
        expect{subject}.to raise_error Wice::WiceGridException
      end
    end
  end

  describe '#get_column_by_model_class_and_column_name(model_class, column_name)' do
    before do
      table.default_model_class = model
    end

    subject(:get_column_by_model_class_and_column_name) do
      table.get_column_by_model_class_and_column_name model, column_name
    end

    it 'returns an instace of ActiveRecord::ConnectionAdapters::Column' do
      is_expected.to be_an ActiveRecord::ConnectionAdapters::Column
    end
  end
end
