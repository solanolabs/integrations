$:<< File.expand_path(File.join(File.dirname(__FILE__), '..'))

load 'gerrit/patchset-created'

describe PatchsetCreated do
  let(:pc) { PatchsetCreated.new }
  it "should initialize defaults" do
    expect(pc.syslog).to eq(true)
    expect(pc.gerrit_prefix).to eq(PatchsetCreated::GERRIT_API_PREFIX)
    expect(pc.endpoints).to eq(PatchsetCreated::SOLANO_CI_REPO_ENDPOINTS)
  end

  describe "#get_ref" do
    let(:response) { File.read(File.join(File.dirname(__FILE__), "fixtures", "gerrit-changes.json")) }

    it "should query for refs with a matching patchet" do
      change_id='abcedfegg'
      uri = URI("#{pc.gerrit_prefix}/changes/?q=#{change_id}\&o=ALL_REVISIONS\&o=DOWNLOAD_COMMANDS") 
      expect(Net::HTTP).to receive(:get).with(uri).and_return(response)
      ref = pc.get_ref(change_id, 1)
      expect(ref).to eq("refs/changes/02/2/1")
    end

    it "should handle refs without a matching patchset" do
      change_id='abcedfegg'
      uri = URI("#{pc.gerrit_prefix}/changes/?q=#{change_id}\&o=ALL_REVISIONS\&o=DOWNLOAD_COMMANDS") 
      expect(Net::HTTP).to receive(:get).with(uri).and_return(response)
      expect{pc.get_ref(change_id, 3)}.to raise_error(PatchsetCreated::MissingPatchset)
    end
  end

  describe "#build_solano_payload" do
    it "should synthesize branch" do
      payload = JSON.parse(pc.build_solano_payload("refs/changes/02/2/2", "abcdef"))
      expect(payload['branch']).to eq("changes/02/2/2")
    end

    it "should synthesize a refspec" do
      payload = JSON.parse(pc.build_solano_payload("refs/changes/02/2/2", "abcdef"))
      expect(payload['refspec'][0]).to eq("+refs/changes/02/2/2:refs/remotes/origin/changes/02/2/2")
    end
  end

  describe "#post_to_solano" do
    let(:ref) { "refs/changes/02/2/2" }
    let(:url) { "https://solano.example.com/foo/bar" }
    let(:commit) { "abcedf" }

    it "should produce a proper Solano payload" do
      http = double(Net::HTTP)

      expect(http).to receive(:use_ssl=)
      expect(http).to receive(:verify_mode=)
      expect(Net::HTTP).to receive(:new).and_return(http)
      expect(http).to receive(:post).with("/foo/bar", pc.build_solano_payload(ref, commit), PatchsetCreated::JSON_HEADERS)
      expect(pc).to receive(:putlog).twice

      pc.post_to_solano(url, ref, commit)
    end
  end
end

