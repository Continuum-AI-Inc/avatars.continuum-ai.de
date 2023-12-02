import type { APIRoute } from "astro";
import { Avatar } from "@continuum-ai/avatars"
import sharp from "sharp";

export const GET: APIRoute = async function({ url }) {
	// Get the correct options from the request
	const token = url.searchParams.get("token")

	const avatar = await Avatar.assemble(token as string);

	const jpeg = avatar.toFormat(sharp.format.jpeg)

	const buffer = await jpeg.toBuffer()

	return new Response(buffer, {
		headers: {
			"content-type": "image/jpeg"
		},
		status: 200
	})
}