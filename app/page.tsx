import Image from "next/image"

export default function Home() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-[#0a0a0a] text-white selection:bg-[#2B65EC] selection:text-white">
      {/* Background gradient effect */}
      <div className="absolute inset-0 bg-[radial-gradient(ellipse_at_center,var(--tw-gradient-stops))] from-[#1a1a1a] via-[#0a0a0a] to-[#0a0a0a] -z-10" />

      <main className="flex flex-col items-center gap-8 p-8 text-center animate-in fade-in zoom-in duration-700">
        <div className="relative">
          <div className="absolute -inset-4 rounded-full bg-linear-to-r from-[#2B65EC] to-[#ADC6FF] opacity-20 blur-xl" />
          <Image
            src="/neptune.svg"
            alt="Neptune Logo"
            width={180}
            height={36}
            priority
            className="relative"
          />
        </div>

        <h1 className="text-5xl font-bold tracking-tighter sm:text-7xl">
          <span className="bg-linear-to-r from-[#2B65EC] via-[#82A5F9] to-[#ADC6FF] bg-clip-text text-transparent">
            Neptune
          </span>
          <span className="mx-4 text-white/50">x</span>
          <span>NextJS</span>
        </h1>

        <div className="mt-8 flex gap-4">
          <a
            href="https://shuttlerust.typeform.com/to/QZC0w0Dx"
            target="_blank"
            rel="noopener noreferrer"
            className="rounded-full bg-white/10 px-6 py-2 text-sm font-medium text-white transition-colors hover:bg-white/20 backdrop-blur-sm border border-white/10"
          >
            Give Feedback
          </a>
          <a
            href="https://docs.neptune.dev/"
            target="_blank"
            rel="noopener noreferrer"
            className="rounded-full px-6 py-2 text-sm font-medium text-white/70 transition-colors hover:text-white"
          >
            Documentation
          </a>
        </div>
      </main>

      <footer className="absolute bottom-8 text-sm text-white/30">
        Simple. Modern. Powerful.
      </footer>
    </div>
  )
}
