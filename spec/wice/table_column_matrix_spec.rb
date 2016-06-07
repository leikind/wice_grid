describe Wice::TableColumnMatrix do
  let(:general_conditions){ 'conditions' }

  let(:table){ Wice::TableColumnMatrix.new }

  it 'should new' do
    expect(table.class).to eq(Wice::TableColumnMatrix)
  end

  it 'should add_condition' do

    table.add_condition('key', general_conditions)

    expect(table.conditions).to include(general_conditions)
  end

  it 'should set default_model_class' do

    table.default_model_class = Dummy

    expect(table.class).to eq(Wice::TableColumnMatrix)
  end

  it 'should get column' do

    table.default_model_class = Dummy

    expect(Dummy.columns).to include(table.get_column_by_model_class_and_column_name(Dummy, :name))
    expect(Dummy.columns).to include(table.get_column_in_default_model_class_by_column_name(:name))
  end

  it 'should get column not initialized' do

    expect { table.get_column_in_default_model_class_by_column_name(:name) }.to raise_error
  end
end
