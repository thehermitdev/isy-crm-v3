function App() {
  return (
    <div className="flex min-h-screen items-center justify-center">
      <div className="w-96 rounded-xl bg-white p-6 shadow-xl border border-slate-100">
        <h1 className="text-2xl font-bold text-primary-900">
          ISY CRM <span className="text-primary-500">v3</span>
        </h1>
        <p className="mt-2 text-slate-800">
          System Status:{' '}
          <span className="font-medium text-success">Online</span>
        </p>
        <p className="mt-4 text-sm text-slate-500">
          Tailwind v4 is configured with Design Tokens.
        </p>
        <button className="mt-6 w-full rounded-lg bg-primary-600 py-2 px-4 text-white hover:bg-primary-500 transition">
          Get Started
        </button>
      </div>
    </div>
  );
}

export default App;
