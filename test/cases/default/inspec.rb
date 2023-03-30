control "k8s-app-validate" do
  impact 1.0
  title "Validate K8s test Application"
  desc "The k8s-app test app should exist and be running"
  
  k8sobjects(api: 'v1', type: 'pods', namespace: 'default', labelSelector: 'app.kubernetes.io/name=bindplane').items.each do |pod|
    describe "#{pod.namespace}/#{pod.name} pod" do
      subject { k8sobject(api: 'v1', type: 'pods', namespace: pod.namespace, name: pod.name) }
      it { should exist }
      it { should be_running }
    end
  end

  describe k8sobjects(api: 'v1', type: 'services', namespace: 'default', labelSelector: 'app.kubernetes.io/name=bindplane') do
    it { should exist }
  end
end
