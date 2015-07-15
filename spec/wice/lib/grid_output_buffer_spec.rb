# encoding: utf-8
module Wice
  describe GridOutputBuffer do

    it 'should to_s' do
      grid = GridOutputBuffer.new
      expect(grid.to_s.class == 'String')
    end

  end
end
