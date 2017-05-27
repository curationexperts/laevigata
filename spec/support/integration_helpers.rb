def show_page
  save_page Rails.root.join('public', 'capybara.html')
  `launchy http://localhost:3000/capybara.html`
end
