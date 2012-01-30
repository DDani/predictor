share_examples_for Recommendify::CCMatrix do

  it "should build a sparsematrix with the correct key" do
    @matrix.ccmatrix.redis_key.should == "recommendify:mymatrix:ccmatrix"
  end

  it "should increment all item counts on addition" do
    Recommendify.redis.hset("recommendify:mymatrix:items", "bar", 2)
    @matrix.add_set("user123", ["foo", "bar"])
    Recommendify.redis.hget("recommendify:mymatrix:items", "bar").to_i.should == 3
    Recommendify.redis.hget("recommendify:mymatrix:items", "foo").to_i.should == 1
  end

  it "should increment all item<->item pairs on set addition" do
    @matrix.ccmatrix["bar", "foo"] = 2
    res = @matrix.add_set("user123", ["foo", "bar", "fnord"])
    res.length.should == 3
    @matrix.ccmatrix["bar", "foo"].should == 3
    @matrix.ccmatrix["foo", "fnord"].should == 1    
  end

  it "should calculate all item<->item pairs (3)" do
    res = @matrix.send(:all_pairs, ["foo", "bar", "fnord"])
    res.length.should == 3
    res.should include("bar:foo")
    res.should include("fnord:foo")
    res.should include("bar:fnord")
  end

  it "should calculate all item<->item pairs (6)" do
    res = @matrix.send(:all_pairs, ["foo", "bar", "fnord", "blubb"])
    res.length.should == 6
    res.should include("bar:foo")
    res.should include("fnord:foo")
    res.should include("bar:fnord")
    res.should include("blubb:foo")
    res.should include("blubb:fnord")
    res.should include("bar:blubb")
  end

end