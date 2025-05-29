const request = require('supertest');
const express = require('express');
const app = require('./index'); // Make sure your Express app is exported

describe('GET /', () => {
  it('should return Hello World!', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.text).toBe('Hello World!');
  });
});
