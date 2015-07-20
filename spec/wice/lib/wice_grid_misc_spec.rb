# encoding: utf-8
module Wice

  context 'assoc_list_to_hash' do
    it 'many elements in assocs' do
      assocs = [:foo1, :foo2, :foo3, :foo4, :foo5]
      out = Wice.assoc_list_to_hash(assocs)
      expect(out).to eq({foo1:{foo2:{foo3:{foo4: :foo5}}}})
    end

    it 'one element in assocs' do
      assocs = [:foo1]
      out = Wice.assoc_list_to_hash(assocs)
      expect(out).to eq(:foo1)
    end

    it 'two elements in assocs' do
      assocs = [:foo1, :foo2]
      out = Wice.assoc_list_to_hash(assocs)
      expect(out).to eq({foo1: :foo2})
    end
  end

  context 'build_includes' do

    it 'symbols + existing symbol' do
      includes = [:a, :b, :c, :d, :e]

      out = Wice.build_includes(includes, [:b])

      expect(out).to eq([:a, :b, :c, :d, :e])
    end

    it 'symbols + non-existing symbol' do
      includes = [:a, :b, :c, :d, :e]

      out = Wice.build_includes(includes, [:x])

      expect(out).to eq([:a, :b, :c, :d, :e, :x])
    end

    it 'symbols + non-existing hash' do
      includes = [:a, :b, :c, :d, :e]

      out = Wice.build_includes(includes, [:x, :y])

      expect(out).to eq([:a, :b, :c, :d, :e, {x: :y}])
    end


    it 'symbols + existing hash' do
      includes = [:a, :b, :c, :d, :e]

      out = Wice.build_includes(includes, [:a, :x])

      expect(out).to eq([{a: :x}, :b, :c, :d, :e])
    end

    it 'symbols with a hash + simple symbol' do
      includes = [{a: :x}, :b, :c, :d, :e]

      out = Wice.build_includes(includes, [:a])

      expect(out).to eq([{a: :x}, :b, :c, :d, :e])
    end

    it 'symbols with a hash + hash' do
      includes = [{a: :x}, :b, :c, :d, :e]

      out = Wice.build_includes(includes, [:a, :x, :y])

      expect(out).to eq([{a: {x: :y}}, :b, :c, :d, :e])
    end

    it 'symbols with a hash + hash (2)' do
      includes = [{a: :x}, :b, :c, :d, :e]

      out = Wice.build_includes(includes, [:a, :x])

      expect(out).to eq([{a: :x}, :b, :c, :d, :e])
    end

    it 'symbols with a hash + the same hash' do
      includes = [{a: :x}]

      out = Wice.build_includes(includes, [:a, :x])

      expect(out).to eq({a: :x})
    end

    it 'symbols with a hash + a deeper hash' do
      includes = [{a: :x}]

      out = Wice.build_includes(includes, [:a, :x, :y])

      expect(out).to eq({a: {x: :y}})
    end

    it 'a deeper hash + a deeper hash' do
      includes = [{a: {x: :y}}]

      out = Wice.build_includes(includes, [:a, :x, :z])

      expect(out).to eq({:a=>[:y, :z]})
    end


    it 'a deeper hash + the same deeper hash' do
      includes = [{a: {x: :y}}]

      out = Wice.build_includes(includes, [:a, :x, :y])

      expect(out).to eq({a: {x: :y}})
    end

    it '1 symbol + hash ' do
      includes = :b

      out = Wice.build_includes(includes, [:a, :x])

      expect(out).to eq([:b, {:a=>:x}])
    end

    it 'nil + hash ' do
      includes = nil

      out = Wice.build_includes(includes, [:a, :x])

      expect(out).to eq({:a=>:x})
    end

    it '1 symbol + nothing' do
      includes = :b

      out = Wice.build_includes(includes, [])

      expect(out).to eq(:b)
    end

    it '1 symbol array + nothing' do
      includes = [:b]

      out = Wice.build_includes(includes, [])

      expect(out).to eq(:b)
    end

    it 'validate_query_model' do
      expect(Wice.get_query_store_model).to eq(WiceGridSerializedQuery)
    end

  end

end
