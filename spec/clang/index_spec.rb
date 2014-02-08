# Copyright, 2014, by Masahiro Sano.
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'spec_helper'

describe Index do
	before :all do
		FileUtils.mkdir_p TMP_DIR
	end

	after :all do
		FileUtils.rm_rf TMP_DIR
	end

	let(:index) { Index.new }

	it "calls dispose_index_debug_unit on GC" do
		expect(Lib).to receive(:dispose_index).with(index)
		expect{index.free}.not_to raise_error
	end

	describe '#parse_translation_unit' do
		it "can parse a source file" do
			tu = index.parse_translation_unit fixture_path("a.c")
			expect(tu).to be_kind_of(TranslationUnit)
		end

		it "raises error when file is not found" do
			expect { index.parse_translation_unit fixture_path("xxxxxxxxx.c") }.to raise_error
		end

		it "can handle command line options" do
		   expect{index.parse_translation_unit(fixture_path("a.c"), ["-std=c++11"])}.not_to raise_error
		end
	end

	describe '#create_translation_unit' do
		before :all do
			system("clang -c #{fixture_path('simple.c')} -emit-ast -o #{TMP_DIR}/simple.ast")
		end

		it "can create translation unit from a ast file" do
			expect(FileTest.exist?("#{TMP_DIR}/simple.ast")).to be_true
			tu = index.create_translation_unit "#{TMP_DIR}/simple.ast"
			expect(tu).to be_kind_of(TranslationUnit)
		end

		it "raises error when file is not found" do
			expect(FileTest.exist?('not_found.ast')).to be_false
			expect { index.create_translation_unit 'not_found.ast' }.to raise_error
		end
	end
end
