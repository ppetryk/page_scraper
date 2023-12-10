require 'rails_helper'

describe Api::HomeController, type: :controller do
  describe 'GET #data' do
    let(:html_document) do
      <<-HTML
        <html>
          <head>
            <meta name="keywords" content="sea beach sand relax">
            <meta name="description" content="Travel Guide 2024">
          </head>
          <body>
            <div>
              <p id="price-box">16.19 euros</p>
              <p id="quantity">4</p>
              <p class="item-name">White Headphones</p>
            </div>
          </body>
        </html>
      HTML
    end

    let(:params) do
      {
        url: 'https://some.site/',
        fields: {
          item: '.item-name',
          price: '#price-box',
          quantity: '#quantity',
          meta: ['keywords', 'description']
        }
      }
    end

    let(:response_json) { JSON.parse(response.body) }

    before do
      allow_any_instance_of(GetHtmlDocument).to receive(:zen_rows_get).and_return html_document
    end

    subject { get :data, params: params }

    it 'succeeds' do
      subject

      expect(response).to be_ok
      expect(response_json['price']).to eq '16.19 euros'
      expect(response_json['quantity']).to eq '4'
      expect(response_json['item']).to eq 'White Headphones'
      expect(response_json['meta']['description']).to eq 'Travel Guide 2024'
      expect(response_json['meta']['keywords']).to eq 'sea beach sand relax'
    end

    context 'when page not found' do
      before do
        allow_any_instance_of(GetHtmlDocument).to receive(:zen_rows_get).and_raise(
          HtmlDocumentNotFound, 'The specified page cannot be found'
        )
      end

      it 'fails with not found' do
        subject

        expect(response).to be_not_found
        expect(response_json['error']).to eq 'The specified page cannot be found'
      end
    end

    context 'when fields not passed' do
      before { params.delete(:fields) }

      it 'fails with bad request' do
        subject

        expect(response).to be_bad_request
        expect(response_json['error']).to eq 'Something went wrong'
      end
    end

    context 'when CSS selector not found on the page' do
      before { params[:fields][:'non-exist'] = '.non-exist-class' }

      it 'succeeds with blank value' do
        subject

        expect(response).to be_ok
        expect(response_json['non-exist']).to be_empty
      end
    end

    context 'when meta tag not found on the page' do
      before { params[:fields][:meta] << 'amazon-id' }

      it 'succeeds with blank value' do
        subject

        expect(response).to be_ok
        expect(response_json['meta']['amazon-id']).to be_empty
      end
    end
  end
end
