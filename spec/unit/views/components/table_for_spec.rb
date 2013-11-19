require 'spec_helper'

describe ActiveAdmin::Views::TableFor do
  describe "creating with the dsl" do

    let(:collection) do
      [Post.new(:title => "First Post"), Post.new(:title => "Second Post"), Post.new(:title => "Third Post")]
    end

    let(:assigns){ { :collection => collection } }
    let(:helpers){ mock_action_view }

    context "when creating a column with a symbol" do
      let(:table) do
        render_arbre_component assigns, helpers do
          table_for(collection) do
            column :title
          end
        end
      end

      it "should create a table header based on the symbol" do
        expect(table.find_by_tag("th").first.content).to eq "Title"
      end

      it "should create a table row for each element in the collection" do
        expect(table.find_by_tag("tr").size).to eq 4 # 1 for head, 3 for rows
      end

      ["First Post", "Second Post", "Third Post"].each_with_index do |content, index|
        it "should create a cell with #{content}" do
          expect(table.find_by_tag("td")[index].content).to eq content
        end
      end
    end

    context "when creating many columns with symbols" do
      let(:table) do
        render_arbre_component assigns, helpers do
          table_for(collection) do
            column :title
            column :created_at
          end
        end
      end

      it "should create a table header based on the symbol" do
        expect(table.find_by_tag("th").first.content).to eq "Title"
        expect(table.find_by_tag("th").last.content).to eq "Created At"
      end

      it "should add a class to each table header based on the col name" do
        expect(table.find_by_tag("th").first.class_list.to_a.join(' ')).to eq "col col-title"
        expect(table.find_by_tag("th").last.class_list.to_a.join(' ')).to eq "col col-created_at"
      end

      it "should create a table row for each element in the collection" do
        expect(table.find_by_tag("tr").size).to eq 4 # 1 for head, 3 for rows
      end

      it "should create a cell for each column" do
        expect(table.find_by_tag("td").size).to eq 6
      end

      it "should add a class for each cell based on the col name" do
        expect(table.find_by_tag("td").first.class_list.to_a.join(' ')).to eq "col col-title"
        expect(table.find_by_tag("td").last.class_list.to_a.join(' ')).to eq "col col-created_at"
      end
    end

    context "when creating a column with block content" do
      let(:table) do
        render_arbre_component assigns, helpers do
          table_for(collection) do
            column :title do |post|
              span(post.title)
            end
          end
        end
      end

      it "should add a class to each table header based on the col name" do
        expect(table.find_by_tag("th").first.class_list).to include("col-title")
      end

      [ "<span>First Post</span>",
        "<span>Second Post</span>",
        "<span>Third Post</span>" ].each_with_index do |content, index|
        it "should create a cell with #{content}" do
          expect(table.find_by_tag("td")[index].content.strip).to eq content
        end
      end
    end

    context "when creating a column with multiple block content" do
      let(:table) do
        render_arbre_component assigns, helpers do
          table_for(collection) do
            column :title do |post|
              span(post.title)
              span(post.title)
            end
          end
        end
      end

      3.times do |index|
        it "should create a cell with multiple elements in row #{index}" do
          expect(table.find_by_tag("td")[index].find_by_tag("span").size).to eq 2
        end
      end
    end


    context "when creating many columns with symbols, blocks and strings" do
      let(:table) do
        render_arbre_component assigns, helpers do
          table_for(collection) do
            column "My Custom Title", :title
            column :created_at , :class=>"datetime"
          end
        end
      end


      it "should add a class to each table header  based on class option or the col name" do
        expect(table.find_by_tag("th").first.class_list.to_a.join(' ')).to eq "col col-my_custom_title"
        expect(table.find_by_tag("th").last.class_list.to_a.join(' ')).to eq "col datetime"
      end

      it "should add a class to each cell based  on class option or the col name" do
        expect(table.find_by_tag("td").first.class_list.to_a.join(' ')).to eq "col col-my_custom_title"
        expect(table.find_by_tag("td").last.class_list.to_a.join(' ')).to eq "col datetime"
      end
    end

    context "when using a single record instead of a collection" do
      let(:table) do
        render_arbre_component nil, helpers do
          table_for Post.new do
            column :title
          end
        end
      end
      it "should render" do
        expect(table.find_by_tag("th").first.content).to eq "Title"
      end
    end


  end

  describe "column sorting" do

    def build_column(*args, &block)
      ActiveAdmin::Views::TableFor::Column.new(*args, &block)
    end

    subject { table_column }

    context "when default" do
      let(:table_column){ build_column(:username) }
      it { should be_sortable }
      its(:sort_key){ should == "username" }
    end

    context "when a block given with no sort key" do
      let(:table_column){ build_column("Username"){ } }
      it { should_not be_sortable }
    end

    context "when a block given with a sort key" do
      let(:table_column){ build_column("Username", :sortable => :username){ } }
      it { should be_sortable }
      its(:sort_key){ should == "username" }
    end

    context "when :sortable => false with a symbol" do
      let(:table_column){ build_column(:username, :sortable => false) }
      it { should_not be_sortable }
    end

    context "when :sortable => false with a symbol and string" do
      let(:table_column){ build_column("Username", :username, :sortable => false) }
      it { should_not be_sortable }
    end

    context "when :sortable column is an association" do
      let(:table_column){ build_column("Category", :category, Post) }
      it { should_not be_sortable }
    end

  end
end
