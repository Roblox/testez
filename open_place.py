import subprocess
import time
import uuid


def main():
	name = str(uuid.uuid4()) + ".rbxlx"
	project = "test-place.project.json"

	try:
		print("Building place file.")
		subprocess.run(["rojo", "build", project, "-o", name], check=True)
	except subprocess.CalledProcessError as e:
		print(e)
		return 1

	editor = subprocess.Popen(["open", "-W", "-n", name])
	server = subprocess.Popen(["rojo", "serve", project])
	try:
		while True:
			if editor.poll() is not None:
				print("Editor closed. Closing rojo.")
				server.terminate()
				break
			if server.poll() is not None:
				print("Rojo server terminated unexpectedly.")
				break
			time.sleep(0.5)
	except KeyboardInterrupt:
		print("Keyboard interrupt detected.")
		editor.terminate()
		server.terminate()
	finally:
		print("Deleting place file.")
		subprocess.run(["rm", name])


if __name__ == "__main__":
	main()