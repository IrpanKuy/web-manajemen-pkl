<?php

namespace App\Http\Middleware;

use App\Models\Approval\MentorRequest;
use App\Models\Instansi\JurnalHarian;
use App\Models\Instansi\PklPlacement;
use App\Models\Siswa\Izin;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use Inertia\Middleware;

class HandleInertiaRequests extends Middleware
{
    /**
     * The root template that's loaded on the first page visit.
     *
     * @see https://inertiajs.com/server-side-setup#root-template
     *
     * @var string
     */
    protected $rootView = 'app';

    /**
     * Determines the current asset version.
     *
     * @see https://inertiajs.com/asset-versioning
     */
    public function version(Request $request): ?string
    {
        return parent::version($request);
    }

    /**
     * Define the props that are shared by default.
     *
     * @see https://inertiajs.com/shared-data
     *
     * @return array<string, mixed>
     */
    public function share(Request $request): array
    {
        return [
            ...parent::share($request),
            //
            'auth' => [
                'user' => $request->user(),
            ],

            'currentRoute' => [
                'name' => Route::currentRouteName(),
            ],
            'flash' => [
                'success' => fn () => $request->session()->get('success'),
                'error'   => fn () => $request->session()->get('error'),
            ],

            // Notification badges untuk pembimbing
            'pembimbingNotifications' => function () use ($request) {
                $user = $request->user();
                if (!$user || $user->role !== 'pembimbing') {
                    return null;
                }

                $pembimbingId = $user->id;

                // Ambil siswa yang dibimbing
                $siswaIds = PklPlacement::where('pembimbing_id', $pembimbingId)
                    ->where('status', 'berjalan')
                    ->pluck('profile_siswa_id');

                return [
                    'jurnal_pending' => JurnalHarian::where('pembimbing_id', $pembimbingId)
                        ->where('status', 'pending')
                        ->count(),
                    'izin_pending' => Izin::whereIn('profile_siswa_id', $siswaIds)
                        ->where('status', 'pending')
                        ->count(),
                    'mentor_request_pending' => MentorRequest::where('pembimbing_baru_id', $pembimbingId)
                        ->where('status', 'pending')
                        ->count(),
                ];
            },
        ];
    }
}

