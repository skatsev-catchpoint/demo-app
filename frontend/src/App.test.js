// filepath: frontend/src/App.test.js
import { render, screen } from '@testing-library/react';
import App from './App'; // or './App' if you split components

test('renders backend message', () => {
  render(<App />);
  expect(screen.getByText(/Backend says:/i)).toBeInTheDocument();
});

