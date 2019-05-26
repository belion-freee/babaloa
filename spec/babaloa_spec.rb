require "byebug"

RSpec.describe Babaloa do
  def hash_data(time = 1)
    (1..time).map {|num|
      {
        col1: "row#{num}-1",
        col2: "row#{num}-2",
        col3: "row#{num}-3",
        col4: "row#{num}-4",
        col5: "row#{num}-5"
      }
    }
  end

  def array_data(time = 1)
    [%w(col1 col2 col3 col4 col5)].concat(
      (1..time).map {|num| ["row#{num}-1","row#{num}-2","row#{num}-3","row#{num}-4","row#{num}-5"] }
    )
  end

  it "correct version" do
    expect(Babaloa::VERSION).to eq("0.1.4")
  end

  describe "to_csv" do
    shared_examples :success do |message, exps|
      it(message){
        acts = subject.split("\n").map {|v| v.split(",") }
        if acts.empty?
          expect(acts).to eq(exps)
        else
          acts.zip(exps) {|act_c, exp_c|
            expect(act_c.size).to eq(exp_c.size)
            act_c.zip(exp_c) {|act, exp|
              expect(act).to eq(exp)
            }
          }
        end
      }
    end

    shared_examples :error do |message, e, em|
      it(message){
        expect{ subject }.to raise_error(e, em)
      }
    end

    # call like this
    # include_examples(
    #         :expect_csv,
    #         [
    #           %w[id 名称 掲載期間 Cost 総予算],
    #           ["1", "Sample Service 1", "2017/02/01 〜  2017/02/13", "50", "¥100.0"],
    #         ]
    #       )

    let(:header) { true }
    let(:options) { {} }
    let(:data) { [] }

    subject { Babaloa.to_csv(data, header, **options) }

    context "when with header option is true" do
      context "invalid class for first args" do
        let(:data) { "test" }
        include_examples(:error, "raise Babaloa::BabaloaError", Babaloa::BabaloaError, "data must be Array")
      end

      context "content is string and header option is true" do
        let(:data) { ["test"] }
        include_examples(:error, "raise Babaloa::BabaloaError", Babaloa::BabaloaError, "content must be Array or Hash")
      end

      context "data content is empty array" do
        let(:data) { [[]] }
        include_examples(:success, "export empty file", [])
      end

      context "data content is empty hash" do
        let(:data) { [{}] }
        include_examples(:success, "export empty file", [])
      end

      context "data is empty and header is true" do
        include_examples(:success, "export empty file", [])
      end

      context "export empty file only header" do
        let(:data) { [%w(col1 col2 col3 col4 col5)] }
        include_examples(:success, "export empty file",
          [%w(col1 col2 col3 col4 col5)]
        )
      end

      context "export file with Array" do
        let(:data) { array_data(5) }
        include_examples(:success, "export file 1 row with header",
          [
            %w(col1 col2 col3 col4 col5),
            %w(row1-1 row1-2 row1-3 row1-4 row1-5),
            %w(row2-1 row2-2 row2-3 row2-4 row2-5),
            %w(row3-1 row3-2 row3-3 row3-4 row3-5),
            %w(row4-1 row4-2 row4-3 row4-4 row4-5),
            %w(row5-1 row5-2 row5-3 row5-4 row5-5)
          ]
        )

        context "data is 1 record" do
          let(:data) { array_data }
          include_examples(:success, "export file 1 row with header",
            [
              %w(col1 col2 col3 col4 col5),
              %w(row1-1 row1-2 row1-3 row1-4 row1-5)
            ]
          )
        end

        context "with sort option by Hash" do
          let(:options) { {sort: {col1: :desc}} }
          include_examples(:success, "export file 5 row order by col1 desc",
            [
              %w(col1 col2 col3 col4 col5),
              %w(row5-1 row5-2 row5-3 row5-4 row5-5),
              %w(row4-1 row4-2 row4-3 row4-4 row4-5),
              %w(row3-1 row3-2 row3-3 row3-4 row3-5),
              %w(row2-1 row2-2 row2-3 row2-4 row2-5),
              %w(row1-1 row1-2 row1-3 row1-4 row1-5)
            ]
          )
        end

        context "with sort option valiable content" do
          let(:data) {
            [
              %w(col1 col2 col3 col4),
              ["2019/11/01", 100, "あかさたな", "test"],
              ["2019/03/01", 1, "宝石", "rspec"],
              ["2018/12/31", 2, "はまやらわ", "rails"],
            ]
          }

          context "by Date" do
            let(:options) { {sort: :col1} }
            include_examples(:success, "row order by col1",
              [
                %w(col1 col2 col3 col4),
                %w(2018/12/31 2 はまやらわ rails),
                %w(2019/03/01 1 宝石 rspec),
                %w(2019/11/01 100 あかさたな test),
              ]
            )
          end

          context "by Number" do
            let(:options) { {sort: :col2} }
            include_examples(:success, "row order by col2",
              [
                %w(col1 col2 col3 col4),
                %w(2019/03/01 1 宝石 rspec),
                %w(2018/12/31 2 はまやらわ rails),
                %w(2019/11/01 100 あかさたな test),
              ]
            )
          end

          context "by Japanese" do
            let(:options) { {sort: :col3} }
            include_examples(:success, "row order by col3",
              [
                %w(col1 col2 col3 col4),
                %w(2019/11/01 100 あかさたな test),
                %w(2018/12/31 2 はまやらわ rails),
                %w(2019/03/01 1 宝石 rspec),
              ]
            )
          end

          context "by English" do
            let(:options) { {sort: :col4} }
            include_examples(:success, "row order by col4",
              [
                %w(col1 col2 col3 col4),
                %w(2018/12/31 2 はまやらわ rails),
                %w(2019/03/01 1 宝石 rspec),
                %w(2019/11/01 100 あかさたな test),
              ]
            )
          end

          context "multiple options" do
            let(:options) {
              {
                sort: {col4: :desc},
                t: { col1: "一番目", col2: "二番目", col3: "三番目", col4: "四番目" }
              }
            }
            include_examples(:success, "row order by col4 desc and transrate",
              [
                %w(一番目 二番目 三番目 四番目),
                %w(2019/11/01 100 あかさたな test),
                %w(2019/03/01 1 宝石 rspec),
                %w(2018/12/31 2 はまやらわ rails),
              ]
            )
          end
        end

        context "with t option by String" do
          let(:options) { {t: { col1: "一番目", col2: "二番目", col3: "三番目", col4: "四番目", col5: "五番目" }} }
          include_examples(:success, "transrated header",
            [
              %w(一番目 二番目 三番目 四番目 五番目),
              %w(row1-1 row1-2 row1-3 row1-4 row1-5),
              %w(row2-1 row2-2 row2-3 row2-4 row2-5),
              %w(row3-1 row3-2 row3-3 row3-4 row3-5),
              %w(row4-1 row4-2 row4-3 row4-4 row4-5),
              %w(row5-1 row5-2 row5-3 row5-4 row5-5)
            ]
          )
        end

        context "with t option with part of transration" do
          let(:options) { {t: { col1: "一番目", col2: "二番目", col3: "三番目"}} }
          include_examples(:success, "transrated header",
            [
              %w(一番目 二番目 三番目 col4 col5),
              %w(row1-1 row1-2 row1-3 row1-4 row1-5),
              %w(row2-1 row2-2 row2-3 row2-4 row2-5),
              %w(row3-1 row3-2 row3-3 row3-4 row3-5),
              %w(row4-1 row4-2 row4-3 row4-4 row4-5),
              %w(row5-1 row5-2 row5-3 row5-4 row5-5)
            ]
          )
        end
      end

      context "export file with Hash" do
        let(:data) { hash_data(5) }

        include_examples(:success, "export file 5 row with header",
          [
            %w(col1 col2 col3 col4 col5),
            %w(row1-1 row1-2 row1-3 row1-4 row1-5),
            %w(row2-1 row2-2 row2-3 row2-4 row2-5),
            %w(row3-1 row3-2 row3-3 row3-4 row3-5),
            %w(row4-1 row4-2 row4-3 row4-4 row4-5),
            %w(row5-1 row5-2 row5-3 row5-4 row5-5)
          ]
        )

        context "data is 1 record" do
          let(:data) { hash_data }
          include_examples(:success, "export file 1 row with header",
            [
              %w(col1 col2 col3 col4 col5),
              %w(row1-1 row1-2 row1-3 row1-4 row1-5)
            ]
          )
        end

        context "with only option by Array" do
          let(:options) { {only: %i(col1 col2)} }
          include_examples(:success, "export file 5 row only col1 col2",
            [
              %w(col1 col2),
              %w(row1-1 row1-2),
              %w(row2-1 row2-2),
              %w(row3-1 row3-2),
              %w(row4-1 row4-2),
              %w(row5-1 row5-2)
            ]
          )
        end

        context "with only option by Symbol" do
          let(:options) { {only: :col1} }
          include_examples(:success, "export file 5 row only col1",
            [
              %w(col1),
              %w(row1-1),
              %w(row2-1),
              %w(row3-1),
              %w(row4-1),
              %w(row5-1)
            ]
          )
        end

        context "with only option by String" do
          let(:options) { {only: "col1"} }
          include_examples(:success, "export file 5 row only col1",
            [
              %w(col1),
              %w(row1-1),
              %w(row2-1),
              %w(row3-1),
              %w(row4-1),
              %w(row5-1)
            ]
          )
        end

        context "with only option by Integer" do
          let(:options) { {only: 1} }
          include_examples(:error, "raise Babaloa::BabaloaError", Babaloa::BabaloaError, "only option must be Array, Symbol, String.")
        end

        context "with except option by Array" do
          let(:options) { {except: %i(col1 col2)} }
          include_examples(:success, "export file 5 row except col1 col2",
            [
              %w(col3 col4 col5),
              %w(row1-3 row1-4 row1-5),
              %w(row2-3 row2-4 row2-5),
              %w(row3-3 row3-4 row3-5),
              %w(row4-3 row4-4 row4-5),
              %w(row5-3 row5-4 row5-5)
            ]
          )
        end

        context "with except option by Symbol" do
          let(:options) { {except: :col1} }
          include_examples(:success, "export file 5 row except col1",
            [
              %w(col2 col3 col4 col5),
              %w(row1-2 row1-3 row1-4 row1-5),
              %w(row2-2 row2-3 row2-4 row2-5),
              %w(row3-2 row3-3 row3-4 row3-5),
              %w(row4-2 row4-3 row4-4 row4-5),
              %w(row5-2 row5-3 row5-4 row5-5)
            ]
          )
        end

        context "with except option by String" do
          let(:options) { {except: "col1"} }
          include_examples(:success, "export file 5 row except col1",
            [
              %w(col2 col3 col4 col5),
              %w(row1-2 row1-3 row1-4 row1-5),
              %w(row2-2 row2-3 row2-4 row2-5),
              %w(row3-2 row3-3 row3-4 row3-5),
              %w(row4-2 row4-3 row4-4 row4-5),
              %w(row5-2 row5-3 row5-4 row5-5)
            ]
          )
        end

        context "with except option by Integer" do
          let(:options) { {except: 1} }
          include_examples(:error, "raise Babaloa::BabaloaError", Babaloa::BabaloaError, "except option must be Array, Symbol, String.")
        end

        context "with sort option by Hash" do
          let(:options) { {sort: {col1: :desc}} }
          include_examples(:success, "export file 5 row order by col1 desc",
            [
              %w(col1 col2 col3 col4 col5),
              %w(row5-1 row5-2 row5-3 row5-4 row5-5),
              %w(row4-1 row4-2 row4-3 row4-4 row4-5),
              %w(row3-1 row3-2 row3-3 row3-4 row3-5),
              %w(row2-1 row2-2 row2-3 row2-4 row2-5),
              %w(row1-1 row1-2 row1-3 row1-4 row1-5)
            ]
          )
        end

        context "with sort option by Symbol" do
          let(:data) { hash_data(5).reverse }
          let(:options) { {sort: :col2} }
          include_examples(:success, "export file 5 row order by col2",
            [
              %w(col1 col2 col3 col4 col5),
              %w(row1-1 row1-2 row1-3 row1-4 row1-5),
              %w(row2-1 row2-2 row2-3 row2-4 row2-5),
              %w(row3-1 row3-2 row3-3 row3-4 row3-5),
              %w(row4-1 row4-2 row4-3 row4-4 row4-5),
              %w(row5-1 row5-2 row5-3 row5-4 row5-5)
            ]
          )
        end

        context "with sort option by String" do
          let(:data) { hash_data(5).map {|h| Hash[ h.map{ |k, v| [k.to_s, v] } ] }.reverse }
          let(:options) { {sort: "col2"} }
          include_examples(:success, "export file 5 row order by col2",
            [
              %w(col1 col2 col3 col4 col5),
              %w(row1-1 row1-2 row1-3 row1-4 row1-5),
              %w(row2-1 row2-2 row2-3 row2-4 row2-5),
              %w(row3-1 row3-2 row3-3 row3-4 row3-5),
              %w(row4-1 row4-2 row4-3 row4-4 row4-5),
              %w(row5-1 row5-2 row5-3 row5-4 row5-5)
            ]
          )
        end

        context "with sort option valiable content" do
          let(:data) {
            [
              {
                col1: "2019/11/01",
                col2: "100",
                col3: "あかさたな",
                col4: "test"
              },
              {
                col1: "2019/03/01",
                col2: "1",
                col3: "宝石",
                col4: "rspec"
              },
              {
                col1: "2018/12/31",
                col2: "2",
                col3: "はまやらわ",
                col4: "rails"
              },
            ]
          }

          context "by Date" do
            let(:options) { {sort: :col1} }
            include_examples(:success, "row order by col1",
              [
                %w(col1 col2 col3 col4),
                %w(2018/12/31 2 はまやらわ rails),
                %w(2019/03/01 1 宝石 rspec),
                %w(2019/11/01 100 あかさたな test),
              ]
            )
          end

          context "by Number" do
            let(:options) { {sort: :col2} }
            include_examples(:success, "row order by col2",
              [
                %w(col1 col2 col3 col4),
                %w(2019/03/01 1 宝石 rspec),
                %w(2018/12/31 2 はまやらわ rails),
                %w(2019/11/01 100 あかさたな test),
              ]
            )
          end

          context "by Japanese" do
            let(:options) { {sort: :col3} }
            include_examples(:success, "row order by col3",
              [
                %w(col1 col2 col3 col4),
                %w(2019/11/01 100 あかさたな test),
                %w(2018/12/31 2 はまやらわ rails),
                %w(2019/03/01 1 宝石 rspec),
              ]
            )
          end

          context "by English" do
            let(:options) { {sort: :col4} }
            include_examples(:success, "row order by col4",
              [
                %w(col1 col2 col3 col4),
                %w(2018/12/31 2 はまやらわ rails),
                %w(2019/03/01 1 宝石 rspec),
                %w(2019/11/01 100 あかさたな test),
              ]
            )
          end

          context "multiple options" do
            let(:options) {
              {
                only: %i(col1 col4),
                sort: {col4: :desc},
                t: { col1: "一番目", col2: "二番目", col3: "三番目", col4: "四番目"}
              }
            }
            include_examples(:success, "order by col4 desc and only col1 col4 and trasrate",
              [
                %w(一番目 四番目),
                %w(2019/11/01 test),
                %w(2019/03/01 rspec),
                %w(2018/12/31 rails),
              ]
            )
          end

          context "default config options" do
            before {
              Babaloa.configure {|config|
                config.definition = {
                  test: {
                    only: %i(col1 col4),
                    except: :col1,
                    sort: {col4: :desc},
                    t: { col1: "一番目", col2: "二番目", col3: "三番目", col4: "四番目"}
                  }
                }
              }
            }
            let(:options) { { name: :test } }
            include_examples(:success, "order by col4 desc and only col4 and trasrate",
              [
                %w(四番目),
                %w(test),
                %w(rspec),
                %w(rails),
              ]
            )
          end

          context "default config options" do
            before {
              Babaloa.configure {|config|
                config.default = {
                  only: %i(col1 col4),
                  except: :col1,
                  sort: {col4: :desc},
                  t: { col1: "一番目", col2: "二番目", col3: "三番目", col4: "四番目"}
                }
              }
            }

            after {
              Babaloa.configure {|config|
                config.default = {}
              }
            }

            include_examples(:success, "order by col4 desc and only col4 and trasrate",
              [
                %w(四番目),
                %w(test),
                %w(rspec),
                %w(rails),
              ]
            )
          end
        end

        context "with sort option by Array" do
          let(:options) { {sort: %i(col1 col2)} }
          include_examples(:error, "raise Babaloa::BabaloaError", Babaloa::BabaloaError, "sort option must be Hash, Symbol, String.")
        end

        context "with t option by Hash" do
          let(:options) { {t: { col1: "一番目", col2: "二番目", col3: "三番目", col4: "四番目", col5: "五番目" }} }
          include_examples(:success, "transrated header",
            [
              %w(一番目 二番目 三番目 四番目 五番目),
              %w(row1-1 row1-2 row1-3 row1-4 row1-5),
              %w(row2-1 row2-2 row2-3 row2-4 row2-5),
              %w(row3-1 row3-2 row3-3 row3-4 row3-5),
              %w(row4-1 row4-2 row4-3 row4-4 row4-5),
              %w(row5-1 row5-2 row5-3 row5-4 row5-5)
            ]
          )
        end

        context "with t option by Array" do
          let(:options) { {t: %i(col1 col2)} }
          include_examples(:error, "raise Babaloa::BabaloaError", Babaloa::BabaloaError, "t option must be Hash")
        end
      end
    end

    context "when with header option is false" do
      let(:header) { false }

      context "data content is empty hash" do
        let(:data) { [{}] }
        include_examples(:error, "raise Babaloa::BabaloaError", Babaloa::BabaloaError, "Header required if content is Hash")
      end

      context 'content is not Array or Hash' do
        let(:data) { ["test"] }
        include_examples(:error, "raise Babaloa::BabaloaError", Babaloa::BabaloaError, "content must be Array or Hash")
      end

      context "data is empty" do
        include_examples(:success, "export empty file", [])
      end

      context "export file with Array" do
        let(:data) { [%w(row1-1 row1-2 row1-3 row1-4 row1-5),%w(row2-1 row2-2 row2-3 row2-4 row2-5)] }
        include_examples(:success, "export file 1 row with header",
          [
            %w(row1-1 row1-2 row1-3 row1-4 row1-5),
            %w(row2-1 row2-2 row2-3 row2-4 row2-5)
          ]
        )
      end
    end

  end
end
