describe Wice do
  describe 'class method' do
    describe '::assoc_list_to_hash(assocs)' do
      subject(:assoc_list_to_hash) {described_class.assoc_list_to_hash assocs}

      context 'when assocs size is 1' do
        let(:assocs) {[:foo1]}

        it 'it returns the first element' do
          is_expected.to be :foo1
        end
      end

      context 'when assocs size is 2' do
        let(:assocs) {%i[foo1 foo2]}

        it 'it returns the the Hash with the key of the first element and the value of the second' do
          is_expected.to eq(foo1: :foo2)
        end
      end

      context 'when assocs size > 2' do
        let(:assocs) {%i[foo1 foo2 foo3 foo4 foo5]}

        it 'it returns the the Hash with the key of the first element and the value as the result of ::assoc_list_to_hash called with the assocs without the first itemd' do
          is_expected.to eq(foo1: {foo2: {foo3: {foo4: :foo5}}})
        end
      end
    end

    describe '::build_includes((existing_includes, new_assocs))' do
      subject(:build_includes) do
        described_class.build_includes existing_includes, new_assocs
      end
      let(:existing_includes) {original_includes.dup}
      let(:original_includes) {[:a, :b, :c, :d, :e]}
      let(:new_assocs) {[:b]}

      it 'calls ::assoc_list_to_hash with new_assocs' do
        expect(described_class).to receive(:assoc_list_to_hash).with(new_assocs)
            .and_call_original
        build_includes
      end

      context 'when existing_includes is an Array of Symbols' do
        context 'and new_assocs is an Array of one Symbol that is present in existing_includes' do
          it 'does not change existing_includes' do
            expect(existing_includes).to eq original_includes
          end

          it 'returns existing_includes' do
            is_expected.to eq original_includes
          end
        end

        context 'and new_assocs is an Array of one Symbol that is not present in existing_includes' do
          let(:new_assocs) {[:x]}

          it 'does not change existing_includes' do
            build_includes
            expect(existing_includes).to eq original_includes
          end

          it 'adds new_assocs to existing_includes' do
            is_expected.to eq original_includes + new_assocs
          end

          it 'returns the updated existing_includes' do
            is_expected.to eq original_includes + new_assocs
          end
        end

        context 'and new_assocs is an Array of two Symbols the first of which is not present in existing_includes' do
          let(:new_assocs) {[:x, :b]}

          it 'does not change existing_includes' do
            build_includes
            expect(existing_includes).to eq original_includes
          end

          it 'returns existing_includes + a Hash built of the new_assocs by ::assoc_list_to_hash' do
            is_expected.to eq existing_includes + [{x: :b}]
          end
        end

        context 'and new_assocs is an Array of two Symbols the first of which is  present in existing_includes and the second one is not' do
          let(:new_assocs) {[:b, :x]}

          it 'changes existing_includes' do
            build_includes
            expect(existing_includes).not_to eq original_includes
          end

          it 'replaces the present symbol in existing_includes with ::assoc_list_to_hash(new_assocs)' do
            is_expected.to eq [:a, {:b=>:x}, :c, :d, :e]
          end

          it 'returns the updated existing_includes' do
            is_expected.to be existing_includes
          end
        end
      end   # when existing_includes is an Array of Symbols

      context 'when existing_includes is an Array that contains a Hash' do
        let(:original_includes) {[{a: :x}, :b, :c, :d, :e]}

        context 'and new_assocs is an Array of one Symbol that is present in existing_includes' do
          it 'does not change existing_includes' do
            expect(build_includes).to eq original_includes
          end

          it 'returns existing_includes' do
            is_expected.to eq original_includes
          end
        end

        context 'and new_assocs is an Array of two Symbols the first of which is  the key of the hash' do
          let(:new_assocs) {[:a, :x]}

          it 'does not change existing_includes' do
            build_includes
            expect(existing_includes).to eq original_includes
          end

          it 'replaces the present symbol in existing_includes with ::assoc_list_to_hash(new_assocs)' do
            is_expected.to eq [{a: :x}, :b, :c, :d, :e]
          end

          it 'returns the existing_includes' do
            is_expected.to be existing_includes
          end
        end

        context 'and new_assocs is an Array of size > 2 where the first and the second items are the key and the value of the Hash in existing_includes' do
          let(:new_assocs) {[:a, :x, :y]}

          it 'changes existing_includes' do
            build_includes
            expect(existing_includes).not_to eq original_includes
          end

          it 'replaces the present the hash in existing_includes with ::assoc_list_to_hash(new_assocs)' do
            is_expected.to eq [{a: {x: :y}}, :b, :c, :d, :e]
          end

          it 'returns the updated existing_includes' do
            is_expected.to be existing_includes
          end
        end
      end   # when existing_includes contains a Hash

      context 'when existing_includes is an Array that contains only one Hash' do
        let(:original_includes) {[a: :x]}

        context 'and new_assocs is an Array of two Symbols the first of which is  the key of the hash' do
          let(:new_assocs) {[:a, :x]}

          it 'does not change existing_includes' do
            build_includes
            expect(existing_includes).to eq original_includes
          end

          it 'returns ::assoc_list_to_hash(new_assocs)' do
            is_expected.to eq(a: :x)
          end
        end

        context 'and new_assocs is an Array of size > 2 where the first and the second items are the key and the value of the Hash in existing_includes' do
          let(:new_assocs) {[:a, :x, :y]}

          it 'changes existing_includes' do
            build_includes
            expect(existing_includes).not_to eq original_includes
          end

          it 'replaces the hash in existing_includes with ::assoc_list_to_hash(new_assocs)' do
            is_expected.to eq(a: {x: :y})
          end

          it 'returns the first element of updated existing_includes' do
            is_expected.to be existing_includes.first
          end
        end
      end   # when existing_includes contains only one Hash

      context 'when existing_includes is an Array that contains only one Hash with a value as a second Hash' do
        let(:original_includes) {[a: {x: :y}]}

        context 'and new_assocs is an Array of size 3 where the first and the second items are the keys of the first and the second Hash in existing_includes but the third is not the value of the second Hash' do
          let(:new_assocs) {[:a, :x, :z]}

          it 'changes existing_includes' do
            build_includes
            expect(existing_includes).not_to eq original_includes
          end

          it 'replaces the value of the hash in existing_includes with an Array whre ther first item is the value in the original existing_includes second Hash and the second is the last item in new_assocs' do
            is_expected.to eq(a: [:y, :z])
          end

          it 'returns the first element of updated existing_includes' do
            is_expected.to be existing_includes.first
          end
        end

        context 'and new_assocs is an Array of size 3 where the first and the second items are the keys of the first and the second Hash in existing_includes and the third is the value of the second Hash' do
          let(:new_assocs) {[:a, :x, :y]}

          it 'does not change existing_includes' do
            build_includes
            expect(existing_includes).to eq original_includes
          end

          it 'returns the Hash of existing_includes' do
            is_expected.to be existing_includes.first
          end
        end
      end   # when existing_includes contains only one Hash with a value as a second Hash

      context 'when existing_includes is an Array that contains only one Symbol' do
        let(:original_includes) {[:b]}

        context 'and new_assocs is an empty Array' do
          let(:new_assocs) {[]}

          it 'does not change existing_includes' do
            build_includes
            expect(existing_includes).to eq original_includes
          end

          it 'returns the Symbol' do
            is_expected.to be existing_includes.first
          end
        end
      end   # when existing_includes is an Array that contains only one Symbol

      context 'when existing_includes is a Symbol' do
        let(:original_includes) {:b}

        context 'and new_assocs is an empty Array' do
          let(:new_assocs) {[]}

          it 'does not change existing_includes' do
            build_includes
            expect(existing_includes).to eq original_includes
          end

          it 'returns the Symbol' do
            is_expected.to be existing_includes
          end
        end

        context 'and new_assocs is an Array that does not start with the symbol' do
          let(:new_assocs) {[:a, :x]}

          it 'does not change existing_includes' do
            build_includes
            expect(existing_includes).to eq original_includes
          end

          it 'returns an Array that contains the symbol and ::assoc_list_to_hash(new_assocs)' do
            is_expected.to eq([:b, described_class.assoc_list_to_hash(new_assocs)])
          end
        end
      end   # when existing_includes is a Symbol

      context 'when existing_includes is nil' do
        let(:original_includes) {}

        context 'and new_assocs is an Array' do
          let(:new_assocs) {[:a, :x]}

          it 'does not change existing_includes' do
            build_includes
            expect(existing_includes).to eq original_includes
          end

          it 'returns  ::assoc_list_to_hash(new_assocs)' do
            is_expected.to eq described_class.assoc_list_to_hash(new_assocs)
          end
        end
      end   # when existing_includes is nil
    end   # ::build_includes((existing_includes, new_assocs))

    describe '::get_query_store_model' do
      subject(:get_query_store_model) {described_class.get_query_store_model}

      it 'returns WiceGridSerializedQuery' do
        is_expected.to be WiceGridSerializedQuery
      end
    end

    describe '::get_string_matching_operators(model)' do
      subject(:get_string_matching_operators) do
        described_class.get_string_matching_operators model
      end
      let(:model) {Dummy}

      it 'returns Wice::ConfigurationProvider.value_for(:STRING_MATCHING_OPERATOR)' do
        is_expected
            .to be Wice::ConfigurationProvider.value_for :STRING_MATCHING_OPERATOR
      end
    end
  end   # class method
end
