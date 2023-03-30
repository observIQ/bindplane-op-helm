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
