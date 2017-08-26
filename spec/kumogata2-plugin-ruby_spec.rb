describe Kumogata2::Plugin::Ruby do
  it do
    expect(1).to eq 1
  end

  describe "#dump" do
    it "JSON format" do

      data = <<-"JSON"
      {
        "Version": "2012-10-17"
      }
      JSON

      opts = {}
      template = Kumogata2::Plugin::Ruby.new(opts).dump(JSON.parse(data))
      expect(template).to eq "template do\n  Version \"2012-10-17\"\nend\n"
    end
  end
end
